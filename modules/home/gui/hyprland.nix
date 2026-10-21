## Hyprland user-level configuration.
## The compositor itself, its portals and the system packages it needs are set up
## on the NixOS side in /modules/nixos/gui/DEs/hyprland. This module only writes
## ~/.config/hypr/hyprland.conf, so it follows whichever specialisation is booted. The
## noctalia (v5) shell is configured in ./noctalia.
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
      style = config.theme.selected.style;
      slot = name: config.lib.stylix.colors.${name};
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
      # Plain playerctl just picks the first MPRIS player it finds (often a paused browser
      # tab), so the media keys go through this instead. It targets whichever player last
      # changed between playing and paused, as recorded by the media-last-player service.
      media-last-player-file = "\${XDG_RUNTIME_DIR:-/tmp}/media-last-player";
      media-control = pkgs.writeShellApplication {
        name = "media-control";
        runtimeInputs = [ pkgs.playerctl ];
        text = ''
          player=$(cat "${media-last-player-file}" 2>/dev/null || true)
          if [ -n "$player" ] && playerctl --player="$player" status >/dev/null 2>&1; then
            exec playerctl --player="$player" "$@"
          fi
          exec playerctl "$@"
        '';
      };
    in
    {
      # Records the player that most recently started or stopped playing, for media-control.
      # A player only counts when its status flips; one that shows up already paused (like
      # a newly opened browser tab) is ignored.
      systemd.user.services.media-last-player = {
        Unit = {
          Description = "Track the most recently played/paused media player";
          PartOf = [ "graphical-session.target" ];
          After = [ "graphical-session.target" ];
        };
        Service = {
          ExecStart = lib.getExe (
            pkgs.writeShellApplication {
              name = "media-last-player";
              runtimeInputs = [ pkgs.playerctl ];
              text = ''
                declare -A seen=()
                playerctl --all-players --follow status --format '{{playerInstance}} {{status}}' |
                  while read -r player status; do
                    [ -n "$player" ] && [ -n "''${status:-}" ] || continue
                    prev=''${seen[$player]:-}
                    seen[$player]=$status
                    [ "$prev" != "$status" ] || continue
                    if [ -n "$prev" ] || [ "$status" = Playing ]; then
                      echo "$player" >"${media-last-player-file}"
                    fi
                  done
              '';
            }
          );
          Restart = "always";
          RestartSec = 2;
        };
        Install.WantedBy = [ "graphical-session.target" ];
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

      # Hyprland only raises a floating window when it's clicked, so a window focused any
      # other way (the Alt+Tab switcher, movefocus, focus falling back after a close) can
      # stay buried under others. This raises whatever window gains focus, like GNOME.
      #
      # Fullscreen windows need extra help: focusing a floating window while one is fullscreen
      # marks it "allowed over fullscreen", and refocusing the fullscreen window never clears
      # that, so it stays covered. Lowering those windows clears the flag; they're sent down
      # most-recently-focused first, which keeps their stacking order among themselves.
      systemd.user.services.hypr-raise-on-focus = {
        Unit = {
          Description = "Raise Hyprland windows when they gain focus";
          PartOf = [ "graphical-session.target" ];
          After = [ "graphical-session.target" ];
        };
        Service = {
          ExecStart = lib.getExe (
            pkgs.writeShellApplication {
              name = "hypr-raise-on-focus";
              runtimeInputs = [
                pkgs.socat
                pkgs.jq
                osConfig.programs.hyprland.package
              ];
              text = ''
                raise() {
                  local addr=$1 cmds
                  cmds=$(hyprctl clients -j | jq -r --arg addr "$addr" '
                    (.[] | select(.address == $addr)) as $w
                    | if $w.fullscreen > 0 then
                        [ .[] | select(.workspace.id == $w.workspace.id and .address != $addr
                                       and .allowedOverFullscreen and (.pinned | not)) ]
                        | sort_by(.focusHistoryID)
                        | map("dispatch alterzorder bottom,address:\(.address)")
                      else [] end
                    | . + ["dispatch alterzorder top,address:\($addr)"]
                    | join("; ")')
                  [ -n "$cmds" ] && hyprctl --batch "$cmds" >/dev/null
                }

                socat -U - "UNIX-CONNECT:$XDG_RUNTIME_DIR/hypr/$HYPRLAND_INSTANCE_SIGNATURE/.socket2.sock" |
                  while IFS= read -r line; do
                    case $line in
                    "activewindowv2>>"?*) raise "0x''${line#activewindowv2>>}" || true ;;
                    esac
                  done
              '';
            }
          );
          Restart = "always";
          RestartSec = 2;
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
            gaps_in = style.gapsIn;
            gaps_out = style.gapsOut;
            border_size = style.borderSize;
            layout = "dwindle";
          }
          // lib.optionalAttrs (style.activeBorder != null) {
            "col.active_border" = lib.mkForce "rgb(${slot style.activeBorder})";
          }
          // lib.optionalAttrs (style.inactiveBorder != null) {
            "col.inactive_border" = lib.mkForce "rgb(${slot style.inactiveBorder})";
          };

          animations.enabled = style.animations;

          decoration = {
            rounding = style.rounding;
            rounding_power = 2;

            shadow = {
              enabled = style.shadow;
              range = 4;
              render_power = 3;
            };

            blur = {
              enabled = style.blur;
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
            "$mod, V, exec, noctalia msg panel-toggle clipboard"
            "$mod SHIFT, V, togglefloating"
            "$mod, F, fullscreen"
            "$mod, D, exec, noctalia msg panel-toggle launcher"
            "$mod, T, exec, theme pick"

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
            # Switch workspaces (up/down mirror left/right, like GNOME's vertical workspaces)
            "ALT CTRL, left, workspace, e-1"
            "ALT CTRL, right, workspace, e+1"
            "ALT CTRL, up, workspace, e-1"
            "ALT CTRL, down, workspace, e+1"
            # GNOME-style switcher overlay: keep holding Alt, Tab / Shift+Tab to pick,
            # release Alt to switch, Esc to cancel.
            "ALT, Tab, exec, noctalia msg window-switcher hold"
            "ALT SHIFT, Tab, exec, noctalia msg window-switcher hold"

            # Media controls
            "CTRL, F9, exec, ${lib.getExe media-control} previous"
            "CTRL, F10, exec, ${lib.getExe media-control} play-pause"
            "CTRL, F11, exec, ${lib.getExe media-control} next"
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
            ", XF86AudioPlay, exec, ${lib.getExe media-control} play-pause"
            ", XF86AudioPause, exec, ${lib.getExe media-control} play-pause"
            ", XF86AudioNext, exec, ${lib.getExe media-control} next"
            ", XF86AudioPrev, exec, ${lib.getExe media-control} previous"
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
