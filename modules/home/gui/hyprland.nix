## Hyprland user-level configuration.
## The compositor itself, its portals and the system packages it needs are set up
## on the NixOS side in /modules/nixos/gui/DEs/hyprland. This module only writes
## ~/.config/hypr/hyprland.lua, so it follows whichever specialisation is booted. The
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
      style = config.theme.selected.style;
      slot = name: config.lib.stylix.colors.${name};
      lua = lib.generators.mkLuaInline;
      mod = "SUPER";
      terminal = "ghostty";
      # hl.bind("<keys>", <dispatcher>, <opts>). `dispatcher` is a raw Lua expression.
      bind = keys: dispatcher: opts: {
        _args = [
          keys
          (lua dispatcher)
        ]
        ++ lib.optional (opts != { }) opts;
      };
      exec = cmd: "hl.dsp.exec_cmd(${lib.generators.toLua { } cmd})";
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

          # With the Lua config, `hyprctl dispatch` takes hl.dsp.* expressions.
          win_sel="window = 'address:$addr'"
          place() {
            hyprctl --batch "dispatch hl.dsp.window.float({ action = 'enable', $win_sel }); dispatch hl.dsp.window.resize({ x = $3, y = $4, $win_sel }); dispatch hl.dsp.window.move({ x = $1, y = $2, $win_sel })" >/dev/null
          }

          if [ "$action" = restore ]; then
            [ -f "$state" ] || exit 0
            read -r floating x y w h <"$state"
            rm "$state"
            place "$x" "$y" "$w" "$h"
            [ "$floating" = true ] || hyprctl dispatch "hl.dsp.window.float({ action = 'disable', $win_sel })" >/dev/null
            exit 0
          fi

          # Remember the original geometry only on the first snap, so left -> right -> restore
          # still returns to where the window started.
          [ -f "$state" ] || jq -r '[.floating, .at[0], .at[1], .size[0], .size[1]] | @tsv' <<<"$win" >"$state"

          # Usable area of the window's monitor: logical size minus the bar's reserved space
          # and the outer gap (plus border, which is drawn outside the window).
          read -r ax ay aw ah < <(hyprctl monitors -j | jq -r \
            --argjson id "$(jq '.monitor' <<<"$win")" \
            --argjson pad ${toString (style.gapsOut + style.borderSize)} '
            .[] | select(.id == $id) | . as $m
            | (if $m.transform % 2 == 1 then [$m.height, $m.width] else [$m.width, $m.height] end) as [$pw, $ph]
            | [ $m.x + $m.reserved[0] + $pad,
                $m.y + $m.reserved[1] + $pad,
                ($pw / $m.scale | floor) - $m.reserved[0] - $m.reserved[2] - 2 * $pad,
                ($ph / $m.scale | floor) - $m.reserved[1] - $m.reserved[3] - 2 * $pad ]
            | @tsv')

          # Space between two side-by-side windows, matching the tiled look.
          inner=${toString (2 * style.gapsIn + 2 * style.borderSize)}
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
                        | map("dispatch hl.dsp.window.alter_zorder({ mode = \"bottom\", window = \"address:\(.address)\" })")
                      else [] end
                    | . + ["dispatch hl.dsp.window.alter_zorder({ mode = \"top\", window = \"address:\($addr)\" })"]
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

        # Hyprland 0.57+ reads hyprland.lua and ignores hyprland.conf. Each attribute in
        # `settings` becomes an `hl.<name>(...)` call; lists make one call per element.
        configType = "lua";

        settings = {
          monitor = {
            output = "";
            mode = "preferred";
            position = "auto";
            scale = 1;
          };

          env = [
            {
              _args = [
                "XCURSOR_SIZE"
                "24"
              ];
            }
            {
              _args = [
                "HYPRCURSOR_SIZE"
                "24"
              ];
            }
          ];

          config = {
            general = {
              gaps_in = style.gapsIn;
              gaps_out = style.gapsOut;
              border_size = style.borderSize;
              layout = "dwindle";
            }
            # Same keys stylix sets, so these override its colors.
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

            input = {
              kb_layout = "us";
              # 2 = hovering only sends scroll events; clicking is what moves keyboard focus.
              follow_mouse = 2;
              touchpad.natural_scroll = true;
            };

            # Mirror the log to stdout so it lands in the journal. The default log in
            # /run/user/... is tmpfs and is gone by the time we can look at a crash.
            # Read it with: journalctl --user -b -1 -u wayland-wm@hyprland.desktop
            debug = {
              disable_logs = false;
              enable_stdout_logs = true;
            };
          };

          # Under UWSM, noctalia is started by its systemd user service. If the plain
          # (non-UWSM) Hyprland session was picked, start it directly instead.
          on = {
            _args = [
              "hyprland.start"
              (lua ''
                function()
                  hl.exec_cmd("uwsm check is-active || noctalia")
                end'')
            ];
          };

          # Namespaces from https://docs.noctalia.dev/noctalia/compositor-settings/hyprland/
          # no_anim stops Hyprland's layer animations fighting noctalia's own.
          layer_rule = {
            match.namespace = "^noctalia-(bar-.+|notification|dock|panel|attached-panel|osd|window-switcher)$";
            blur = true;
            blur_popups = true;
            ignore_alpha = 0.5;
            no_anim = true;
          };

          window_rule = [
            # Float everything so windows stack like a regular desktop; SUPER+SHIFT+V tiles one again.
            {
              match.class = ".*";
              float = true;
            }
            {
              match.class = "^dev\\.noctalia\\.Noctalia$";
              float = true;
              size = "1080 920";
            }
            # Don't idle (screen off / suspend) while any window is fullscreen.
            {
              match.class = ".*";
              idle_inhibit = "fullscreen";
            }
          ];

          gesture = {
            fingers = 3;
            direction = "horizontal";
            action = "workspace";
          };

          bind = [
            (bind "${mod} + Return" (exec terminal) { })
            (bind "${mod} + C" "hl.dsp.window.close()" { })
            # Wayland apps (Firefox, GTK, etc.) don't handle Alt+F4 themselves; the compositor has to.
            (bind "ALT + F4" "hl.dsp.window.close()" { })
            (bind "${mod} + M" "hl.dsp.exit()" { })
            (bind "${mod} + V" (exec "noctalia msg panel-toggle clipboard") { })
            (bind "${mod} + SHIFT + V" "hl.dsp.window.float({ action = \"toggle\" })" { })
            (bind "${mod} + F" "hl.dsp.window.fullscreen()" { })
            (bind "${mod} + D" (exec "noctalia msg panel-toggle launcher") { })
            (bind "${mod} + T" (exec "theme pick") { })

            # Focus and move windows with the keyboard
            (bind "${mod} + H" "hl.dsp.focus({ direction = \"left\" })" { })
            (bind "${mod} + J" "hl.dsp.focus({ direction = \"down\" })" { })
            (bind "${mod} + K" "hl.dsp.focus({ direction = \"up\" })" { })
            (bind "${mod} + L" "hl.dsp.focus({ direction = \"right\" })" { })
            # GNOME-style snapping: maximize, left/right half, restore. Unlike Hyprland's
            # own maximize, any number of windows can be maximized at once.
            (bind "${mod} + up" (exec "${lib.getExe hypr-snap} maximize") { })
            (bind "${mod} + down" (exec "${lib.getExe hypr-snap} restore") { })
            (bind "${mod} + left" (exec "${lib.getExe hypr-snap} left") { })
            (bind "${mod} + right" (exec "${lib.getExe hypr-snap} right") { })
            # Switch workspaces (up/down mirror left/right, like GNOME's vertical workspaces)
            (bind "ALT + CTRL + left" "hl.dsp.focus({ workspace = \"e-1\" })" { })
            (bind "ALT + CTRL + right" "hl.dsp.focus({ workspace = \"e+1\" })" { })
            (bind "ALT + CTRL + up" "hl.dsp.focus({ workspace = \"e-1\" })" { })
            (bind "ALT + CTRL + down" "hl.dsp.focus({ workspace = \"e+1\" })" { })
            # GNOME-style switcher overlay: keep holding Alt, Tab / Shift+Tab to pick,
            # release Alt to switch, Esc to cancel.
            (bind "ALT + Tab" (exec "noctalia msg window-switcher hold") { })
            (bind "ALT + SHIFT + Tab" (exec "noctalia msg window-switcher hold") { })

            # Screenshots with GNOME's keys, taken by noctalia (it saves to ~/Pictures/Screenshots
            # and copies to the clipboard). Ctrl+Print opens the annotation editor on a region.
            (bind "Print" (exec "noctalia msg screenshot-region") { })
            (bind "SHIFT + Print" (exec "noctalia msg screenshot-fullscreen all") { })
            (bind "ALT + Print" (exec "noctalia msg screenshot-window") { })
            (bind "CTRL + Print" (exec "noctalia msg screenshot-region --annotate") { })

            # Media controls
            (bind "CTRL + F9" (exec "${lib.getExe media-control} previous") { })
            (bind "CTRL + F10" (exec "${lib.getExe media-control} play-pause") { })
            (bind "CTRL + F11" (exec "${lib.getExe media-control} next") { })
          ]
          ++ (builtins.concatLists (
            builtins.genList (
              i:
              let
                ws = toString (i + 1);
              in
              [
                (bind "${mod} + ${ws}" "hl.dsp.focus({ workspace = ${ws} })" { })
                (bind "${mod} + SHIFT + ${ws}" "hl.dsp.window.move({ workspace = ${ws} })" { })
              ]
            ) 9
          ))
          # Nudge and resize the active window with the keyboard, repeating while held.
          ++ map (b: bind b.keys b.dsp { repeating = true; }) [
            {
              keys = "${mod} + ALT + left";
              dsp = "hl.dsp.window.move({ x = -40, y = 0, relative = true })";
            }
            {
              keys = "${mod} + ALT + right";
              dsp = "hl.dsp.window.move({ x = 40, y = 0, relative = true })";
            }
            {
              keys = "${mod} + ALT + up";
              dsp = "hl.dsp.window.move({ x = 0, y = -40, relative = true })";
            }
            {
              keys = "${mod} + ALT + down";
              dsp = "hl.dsp.window.move({ x = 0, y = 40, relative = true })";
            }
            {
              keys = "${mod} + CTRL + left";
              dsp = "hl.dsp.window.resize({ x = -40, y = 0, relative = true })";
            }
            {
              keys = "${mod} + CTRL + right";
              dsp = "hl.dsp.window.resize({ x = 40, y = 0, relative = true })";
            }
            {
              keys = "${mod} + CTRL + up";
              dsp = "hl.dsp.window.resize({ x = 0, y = -40, relative = true })";
            }
            {
              keys = "${mod} + CTRL + down";
              dsp = "hl.dsp.window.resize({ x = 0, y = 40, relative = true })";
            }
          ]
          # Function keys (like brightness control, music control, etc).
          # repeating = repeat while held, locked = also works while the screen is locked.
          ++
            map
              (
                b:
                bind b.key (exec b.cmd) {
                  repeating = true;
                  locked = true;
                }
              )
              [
                {
                  key = "XF86AudioRaiseVolume";
                  cmd = "noctalia msg volume-up";
                }
                {
                  key = "XF86AudioLowerVolume";
                  cmd = "noctalia msg volume-down";
                }
                {
                  key = "XF86MonBrightnessUp";
                  cmd = "noctalia msg brightness-up";
                }
                {
                  key = "XF86MonBrightnessDown";
                  cmd = "noctalia msg brightness-down";
                }
                {
                  key = "XF86KbdBrightnessUp";
                  cmd = "noctalia msg keyboard-backlight-up";
                }
                {
                  key = "XF86KbdBrightnessDown";
                  cmd = "noctalia msg keyboard-backlight-down";
                }
              ]
          ++ map (b: bind b.key (exec b.cmd) { locked = true; }) [
            {
              key = "XF86AudioMute";
              cmd = "noctalia msg volume-mute";
            }
            {
              key = "XF86AudioMicMute";
              cmd = "noctalia msg mic-mute";
            }
            {
              key = "CTRL + SHIFT + ALT + M";
              cmd = "noctalia msg mic-mute";
            }
            {
              key = "XF86AudioPlay";
              cmd = "${lib.getExe media-control} play-pause";
            }
            {
              key = "XF86AudioPause";
              cmd = "${lib.getExe media-control} play-pause";
            }
            {
              key = "XF86AudioNext";
              cmd = "${lib.getExe media-control} next";
            }
            {
              key = "XF86AudioPrev";
              cmd = "${lib.getExe media-control} previous";
            }
            {
              key = "XF86KbdLightOnOff";
              cmd = "noctalia msg keyboard-backlight-toggle";
            }
          ]
          ++ [
            # Tapping Super on its own opens the launcher, like GNOME's Activities search.
            # Release binds on a modifier only fire if no other key was pressed with it.
            (bind "SUPER + Super_L" (exec "noctalia msg panel-toggle launcher") { release = true; })

            (bind "${mod} + mouse:272" "hl.dsp.window.drag()" { mouse = true; })
            (bind "${mod} + mouse:273" "hl.dsp.window.resize()" { mouse = true; })
          ];
        };
      };
    }
  );
}
