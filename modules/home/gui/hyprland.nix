## Hyprland user-level configuration.
## The compositor itself, its portals and the system packages it needs are set up
## on the NixOS side in /modules/nixos/gui/DEs/hyprland. This module only writes
## ~/.config/hypr/hyprland.conf and the noctalia (v5) shell config, so it follows whichever
## specialisation is booted. noctalia is configured here rather than on the NixOS side so
## the stylix noctalia target can theme it, and `theme set` swaps its palette live.
{
  config,
  lib,
  pkgs,
  osConfig,
  ...
}:
{
  options.hyprland.enable = lib.mkOption {
    type = lib.types.bool;
    default = osConfig != null && (osConfig.hyprland.enable or false);
    defaultText = lib.literalExpression "osConfig.hyprland.enable";
    description = "Whether to write the Hyprland user configuration";
  };

  config = lib.mkIf config.hyprland.enable (
    let
      inherit (config.wayland.windowManager.hyprland.settings) general;
      # GNOME-style maximize / half-screen snapping for floating windows. Hyprland's own
      # maximize (fullscreen 1) only allows one window per workspace, so this just moves
      # and resizes the window to fill the usable area instead. The pre-snap geometry is
      # kept so `restore` puts the window back.
      hypr-snap = pkgs.writeShellApplication {
        name = "hypr-snap";
        runtimeInputs = [ pkgs.jq ];
        text = ''
          action=$1
          win=$(hyprctl activewindow -j)
          addr=$(jq -r '.address // empty' <<<"$win")
          [ -n "$addr" ] || exit 0
          [ "$(jq -r '.fullscreen' <<<"$win")" = "0" ] || exit 0

          state_dir="''${XDG_RUNTIME_DIR:-/tmp}/hypr-snap"
          mkdir -p "$state_dir"
          state="$state_dir/$addr"

          place() {
            hyprctl --batch "dispatch setfloating address:$addr; dispatch resizewindowpixel exact $3 $4,address:$addr; dispatch movewindowpixel exact $1 $2,address:$addr" >/dev/null
          }

          if [ "$action" = restore ]; then
            [ -f "$state" ] || exit 0
            read -r floating x y w h <"$state"
            rm "$state"
            place "$x" "$y" "$w" "$h"
            [ "$floating" = true ] || hyprctl dispatch settiled "address:$addr" >/dev/null
            exit 0
          fi

          # Remember the original geometry only on the first snap, so left -> right -> restore
          # still returns to where the window started.
          [ -f "$state" ] || jq -r '[.floating, .at[0], .at[1], .size[0], .size[1]] | @tsv' <<<"$win" >"$state"

          # Usable area of the window's monitor: logical size minus the bar's reserved space
          # and the outer gap (plus border, which is drawn outside the window).
          read -r ax ay aw ah < <(hyprctl monitors -j | jq -r \
            --argjson id "$(jq '.monitor' <<<"$win")" \
            --argjson pad ${toString (general.gaps_out + general.border_size)} '
            .[] | select(.id == $id) | . as $m
            | (if $m.transform % 2 == 1 then [$m.height, $m.width] else [$m.width, $m.height] end) as [$pw, $ph]
            | [ $m.x + $m.reserved[0] + $pad,
                $m.y + $m.reserved[1] + $pad,
                ($pw / $m.scale | floor) - $m.reserved[0] - $m.reserved[2] - 2 * $pad,
                ($ph / $m.scale | floor) - $m.reserved[1] - $m.reserved[3] - 2 * $pad ]
            | @tsv')

          # Space between two side-by-side windows, matching the tiled look.
          inner=${toString (2 * general.gaps_in + 2 * general.border_size)}
          half=$(((aw - inner) / 2))

          case "$action" in
          maximize) place "$ax" "$ay" "$aw" "$ah" ;;
          left) place "$ax" "$ay" "$half" "$ah" ;;
          right) place "$((ax + half + inner))" "$ay" "$((aw - half - inner))" "$ah" ;;
          *)
            echo "usage: hypr-snap maximize|left|right|restore" >&2
            exit 1
            ;;
          esac
        '';
      };
    in
    {
      programs.noctalia = {
        enable = true;
        # Started by graphical-session.target, which only the UWSM session reaches.
        systemd.enable = true;
        # Anything changed in noctalia's settings window lands in
        # ~/.local/state/noctalia/settings.toml and wins over this (including stylix's colors).
        settings = {
          shell = {
            avatar_path = "${config.home.homeDirectory}/.face";
            # Otherwise apps launched from noctalia die whenever its service restarts.
            launch_apps_as_systemd_services = true;
            # The wizard writes its picks to settings.toml, which would override stylix.
            setup_wizard_enabled = false;
            # Push wallpaper and colors to noctalia-greeter whenever they change.
            greeter_sync.auto_sync = true;
            # GNOME orders Alt+Tab by most recently used, so a quick Alt+Tab flips between
            # the last two windows.
            window_switcher_mru = true;
          };
          # Let the launcher find open windows by name too, not just apps.
          panels.launcher_global_windows = true;
          wallpaper.directory = "${config.home.homeDirectory}/Pictures/Wallpapers";
          # Default start lane plus small system gauges (no text values) after the workspaces.
          bar.default.start = [
            "launcher"
            "wallpaper"
            "cpu"
            "temp"
            "ram"
            "workspaces"
          ];
          widget =
            let
              gauge = stat: {
                type = "sysmon";
                inherit stat;
                visualization = "gauge";
                show_value = false;
              };
            in
            {
              cpu = gauge "cpu_usage";
              temp = gauge "cpu_temp";
              ram = gauge "ram_used";
              clock.format = "{:%-I:%M %p}";
              # Icon only, no SSID.
              network.show_label = false;
            };
          # Same timings the GNOME setup used: screen off after 10 mins, suspend after 15.
          # Only locks when suspending (lockscreen.lock_before_suspend defaults to true).
          # Idle is held off by Wayland idle inhibitors: fullscreen windows (windowrule
          # below) and audio playback (wayland-pipewire-idle-inhibit below).
          idle = {
            behavior_order = [
              "screen-off"
              "suspend"
            ];
            behavior.screen-off = {
              action = "screen_off";
              enabled = true;
              timeout = 600;
            };
            behavior.suspend = {
              action = "lock_and_suspend";
              enabled = true;
              timeout = 900;
            };
          };
        };
      };

      # Holds an idle inhibitor while anything is playing audio through PipeWire, so music
      # or videos keep the screen on and stop auto-suspend (GNOME used caffeine for this).
      systemd.user.services.wayland-pipewire-idle-inhibit = {
        Unit = {
          Description = "Inhibit idle while audio is playing";
          PartOf = [ "graphical-session.target" ];
          After = [
            "graphical-session.target"
            "pipewire.service"
          ];
        };
        Service = {
          ExecStart = lib.getExe pkgs.wayland-pipewire-idle-inhibit;
          Restart = "on-failure";
          RestartSec = 5;
        };
        Install.WantedBy = [ "graphical-session.target" ];
      };
      # noctalia draws the wallpaper (stylix hands it the image), so hyprpaper would just be
      # a second wallpaper underneath it.
      stylix.targets.hyprland.hyprpaper.enable = false;

      wayland.windowManager.hyprland = {
        enable = true;

        package = null;
        portalPackage = null;
        systemd.enable = false;

        settings = {
          "$mod" = "SUPER";
          "$terminal" = "ghostty";

          monitor = [ ",preferred,auto,1" ];

          env = [
            "XCURSOR_SIZE,24"
            "HYPRCURSOR_SIZE,24"
          ];

          general = {
            gaps_in = 5;
            gaps_out = 10;
            border_size = 2;
            layout = "dwindle";
          };

          decoration = {
            rounding = 20;
            rounding_power = 2;

            shadow = {
              enabled = true;
              range = 4;
              render_power = 3;
            };

            blur = {
              enabled = true;
              size = 3;
              passes = 2;
              vibrancy = 0.1696;
            };
          };

          # Under UWSM, noctalia is started by its systemd user service. If the plain
          # (non-UWSM) Hyprland session was picked, start it directly instead.
          exec-once = [ "uwsm check is-active || noctalia" ];

          # Namespaces from https://docs.noctalia.dev/noctalia/compositor-settings/hyprland/
          # no_anim stops Hyprland's layer animations fighting noctalia's own.
          layerrule =
            let
              noctalia = "match:namespace ^noctalia-(bar-.+|notification|dock|panel|attached-panel|osd|window-switcher)$";
            in
            [
              "blur on, ${noctalia}"
              "blur_popups on, ${noctalia}"
              "ignore_alpha 0.5, ${noctalia}"
              "no_anim on, ${noctalia}"
            ];

          windowrule = [
            # Float everything so windows stack like a regular desktop; SUPER+V tiles one again.
            "float on, match:class .*"
            "float on, match:class ^dev\\.noctalia\\.Noctalia$"
            "size 1080 920, match:class ^dev\\.noctalia\\.Noctalia$"
            # Don't idle (screen off / suspend) while any window is fullscreen.
            "idle_inhibit fullscreen, match:class .*"
          ];

          input = {
            kb_layout = "us";
            # 2 = hovering only sends scroll events; clicking is what moves keyboard focus.
            follow_mouse = 2;
            touchpad.natural_scroll = true;
          };

          gesture = "3, horizontal, workspace";

          bind = [
            "$mod, Return, exec, $terminal"
            "$mod, C, killactive"
            "$mod, M, exit"
            "$mod, V, togglefloating"
            "$mod, F, fullscreen"
            "$mod, D, exec, noctalia msg panel-toggle launcher"

            # Focus and move windows with the keyboard
            "$mod, H, movefocus, l"
            "$mod, J, movefocus, d"
            "$mod, K, movefocus, u"
            "$mod, L, movefocus, r"
            # GNOME-style snapping: maximize, left/right half, restore. Unlike Hyprland's
            # own maximize, any number of windows can be maximized at once.
            "$mod, up, exec, ${lib.getExe hypr-snap} maximize"
            "$mod, down, exec, ${lib.getExe hypr-snap} restore"
            "$mod, left, exec, ${lib.getExe hypr-snap} left"
            "$mod, right, exec, ${lib.getExe hypr-snap} right"
            "$mod SHIFT, left, movewindow, l"
            "$mod SHIFT, right, movewindow, r"
            "$mod SHIFT, up, movewindow, u"
            "$mod SHIFT, down, movewindow, d"
            # GNOME-style switcher overlay: keep holding Alt, Tab / Shift+Tab to pick,
            # release Alt to switch, Esc to cancel.
            "ALT, Tab, exec, noctalia msg window-switcher hold"
            "ALT SHIFT, Tab, exec, noctalia msg window-switcher hold"

            # Media controls
            "CTRL, F9, exec, playerctl previous"
            "CTRL, F10, exec, playerctl play-pause"
            "CTRL, F11, exec, playerctl next"
          ]
          ++ (builtins.concatLists (
            builtins.genList (
              i:
              let
                ws = i + 1;
              in
              [
                "$mod, ${toString ws}, workspace, ${toString ws}"
                "$mod SHIFT, ${toString ws}, movetoworkspace, ${toString ws}"
              ]
            ) 9
          ));

          # Nudge and resize the active window with the keyboard, repeating while held.
          binde = [
            "$mod ALT, left, moveactive, -40 0"
            "$mod ALT, right, moveactive, 40 0"
            "$mod ALT, up, moveactive, 0 -40"
            "$mod ALT, down, moveactive, 0 40"
            "$mod CTRL, left, resizeactive, -40 0"
            "$mod CTRL, right, resizeactive, 40 0"
            "$mod CTRL, up, resizeactive, 0 -40"
            "$mod CTRL, down, resizeactive, 0 40"
          ];

          # Function keys (like brightness control, music control, etc).
          # e = repeat while held, l = also works while the screen is locked.
          bindel = [
            ", XF86AudioRaiseVolume, exec, noctalia msg volume-up"
            ", XF86AudioLowerVolume, exec, noctalia msg volume-down"
            ", XF86MonBrightnessUp, exec, noctalia msg brightness-up"
            ", XF86MonBrightnessDown, exec, noctalia msg brightness-down"
            ", XF86KbdBrightnessUp, exec, noctalia msg keyboard-backlight-up"
            ", XF86KbdBrightnessDown, exec, noctalia msg keyboard-backlight-down"
          ];
          bindl = [
            ", XF86AudioMute, exec, noctalia msg volume-mute"
            ", XF86AudioMicMute, exec, noctalia msg mic-mute"
            ", XF86AudioPlay, exec, noctalia msg media toggle"
            ", XF86AudioPause, exec, noctalia msg media toggle"
            ", XF86AudioNext, exec, noctalia msg media next"
            ", XF86AudioPrev, exec, noctalia msg media previous"
            ", XF86KbdLightOnOff, exec, noctalia msg keyboard-backlight-toggle"
          ];

          # Tapping Super on its own opens the launcher, like GNOME's Activities search.
          # Release binds on a modifier only fire if no other key was pressed with it.
          bindr = [ "SUPER, Super_L, exec, noctalia msg panel-toggle launcher" ];

          bindm = [
            "$mod, mouse:272, movewindow"
            "$mod, mouse:273, resizewindow"
          ];
        };
      };
    }
  );
}
