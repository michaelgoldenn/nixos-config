## niri user-level configuration.
## The compositor itself is set up on the NixOS side in /modules/nixos/gui/DEs/niri.nix.
## This module only writes ~/.config/niri/config.kdl (niri reloads it on change, so theme
## switches apply live). The noctalia shell is configured in ./noctalia, and the services
## shared with Hyprland (media keys, idle inhibit) in ./wayland-session.nix.
## Config reference: https://github.com/niri-wm/niri/wiki/Configuration:-Introduction
{
  config,
  lib,
  osConfig,
  ...
}:
{
  options.niri.enable = lib.mkOption {
    type = lib.types.bool;
    default = osConfig != null && (osConfig.niri.enable or false);
    defaultText = lib.literalExpression "osConfig.niri.enable";
    description = "Whether to write the niri user configuration";
  };

  config = lib.mkIf config.niri.enable (
    let
      style = config.theme.selected.style;
      color = name: "#${config.lib.stylix.colors.${name}}";
      activeBorder = color (if style.activeBorder != null then style.activeBorder else "base0D");
      inactiveBorder = color (if style.inactiveBorder != null then style.inactiveBorder else "base03");
      terminal = "ghostty";
      media = lib.getExe config.waylandSession.mediaControl;
      onOff = enabled: if enabled then "on" else "off";

      workspaceBinds = lib.concatStrings (
        builtins.genList (
          i:
          let
            ws = toString (i + 1);
          in
          "    Mod+${ws} { focus-workspace ${ws}; }\n    Mod+Shift+${ws} { move-column-to-workspace ${ws}; }\n"
        ) 9
      );
    in
    {
      xdg.configFile."niri/config.kdl".text = ''
        input {
            keyboard {
                xkb {
                    layout "us"
                }
            }
            touchpad {
                tap
                natural-scroll
            }
        }

        // noctalia's screenshots go to ~/Pictures/Screenshots too; this is for niri's own.
        screenshot-path "~/Pictures/Screenshots/Screenshot from %Y-%m-%d %H-%M-%S.png"

        hotkey-overlay {
            skip-at-startup
        }

        layout {
            // Hyprland's gaps_in is half the space between two windows; niri's is all of it.
            gaps ${toString (2 * style.gapsIn)}
            focus-ring {
                off
            }
            border {${lib.optionalString (style.borderSize == 0) "\n        off"}
                width ${toString style.borderSize}
                active-color "${activeBorder}"
                inactive-color "${inactiveBorder}"
            }
            shadow {
                ${onOff style.shadow}
            }
            // Transparent so noctalia's wallpaper (placed in the backdrop below) shows
            // through and stays put while scrolling between workspaces.
            background-color "transparent"
        }

        animations {
            ${onOff style.animations}
        }

        overview {
            workspace-shadow {
                off
            }
        }

        // noctalia's Alt+Tab switcher is bound below instead of niri's built-in one.
        recent-windows {
            off
        }

        // Rounded corners, clipped so window contents follow them.
        window-rule {
            geometry-corner-radius ${toString style.rounding}
            clip-to-geometry true
        }

        // noctalia settings window floats at a fixed size.
        window-rule {
            match app-id="^dev\\.noctalia\\.Noctalia$"
            open-floating true
            default-column-width { fixed 1080; }
            default-window-height { fixed 920; }
        }

        ${
          if style.blur then
            ''
              // Blur behind translucent windows and noctalia's surfaces. xray off samples
              // what's actually behind them instead of the wallpaper.
              window-rule {
                  background-effect {
                      blur true
                      xray false
                  }
              }
              layer-rule {
                  match namespace="^noctalia-"
                  background-effect {
                      blur true
                      xray false
                  }
              }
              blur {
                  passes 2
                  offset 3.0
              }''
          else
            ''
              // noctalia asks for blur on its own surfaces; turn it off to match the theme.
              layer-rule {
                  match namespace="^noctalia-"
                  background-effect {
                      blur false
                  }
              }''
        }

        // Stationary wallpaper: noctalia's wallpaper layer sits in niri's backdrop
        // (needs noctalia's [backdrop] section disabled, which it is).
        layer-rule {
            match namespace="^noctalia-wallpaper"
            place-within-backdrop true
        }

        debug {
            // Lets noctalia's notification actions and window activation focus windows.
            honor-xdg-activation-with-invalid-serial
        }

        binds {
            // Tapping Super on its own opens the launcher, like GNOME's Activities search.
            // Release binds on a modifier only fire if no other key was pressed with it.
            Mod {
                release { spawn-sh "noctalia msg panel-toggle launcher"; }
            }

            Mod+Return { spawn "${terminal}"; }
            Mod+C { close-window; }
            // Wayland apps (Firefox, GTK, etc.) don't handle Alt+F4 themselves.
            Alt+F4 { close-window; }
            Mod+M { quit; }
            Mod+Shift+V { toggle-window-floating; }
            Mod+F { fullscreen-window; }
            Mod+O repeat=false { toggle-overview; }

            // Focus with the keyboard. Columns scroll left/right; windows stack within a
            // column, and past the top/bottom window this moves between workspaces.
            Mod+H { focus-column-left; }
            Mod+L { focus-column-right; }
            Mod+J { focus-window-or-workspace-down; }
            Mod+K { focus-window-or-workspace-up; }
            Mod+Left { focus-column-left; }
            Mod+Right { focus-column-right; }
            // Closest thing to GNOME's maximize / restore for a scrolling layout:
            // Super+Up fills the screen with the column, Super+Down drops it to half width.
            Mod+Up { maximize-column; }
            Mod+Down { set-column-width "50%"; }

            // Move and resize the focused column/window with the keyboard.
            Mod+Alt+Left { move-column-left; }
            Mod+Alt+Right { move-column-right; }
            Mod+Alt+Up { move-window-up-or-to-workspace-up; }
            Mod+Alt+Down { move-window-down-or-to-workspace-down; }
            Mod+Ctrl+Left { set-column-width "-10%"; }
            Mod+Ctrl+Right { set-column-width "+10%"; }
            Mod+Ctrl+Up { set-window-height "-10%"; }
            Mod+Ctrl+Down { set-window-height "+10%"; }

            // Switch workspaces. niri's workspaces stack vertically like GNOME's;
            // left/right mirror up/down.
            Ctrl+Alt+Left { focus-workspace-up; }
            Ctrl+Alt+Up { focus-workspace-up; }
            Ctrl+Alt+Right { focus-workspace-down; }
            Ctrl+Alt+Down { focus-workspace-down; }
            Mod+WheelScrollDown cooldown-ms=150 { focus-workspace-down; }
            Mod+WheelScrollUp cooldown-ms=150 { focus-workspace-up; }
            Mod+WheelScrollRight { focus-column-right; }
            Mod+WheelScrollLeft { focus-column-left; }
        ${workspaceBinds}
            Mod+D { spawn-sh "noctalia msg panel-toggle launcher"; }
            Mod+V { spawn-sh "noctalia msg panel-toggle clipboard"; }
            Mod+T { spawn-sh "theme pick"; }

            // GNOME-style switcher overlay: keep holding Alt, Tab / Shift+Tab to pick,
            // release Alt to switch, Esc to cancel.
            Alt+Tab { spawn-sh "noctalia msg window-switcher hold"; }
            Alt+Shift+Tab { spawn-sh "noctalia msg window-switcher hold"; }

            // Screenshots with GNOME's keys, taken by noctalia (saved to ~/Pictures/Screenshots
            // and copied to the clipboard). Ctrl+Print opens the annotation editor on a region.
            Print { spawn-sh "noctalia msg screenshot-region"; }
            Shift+Print { spawn-sh "noctalia msg screenshot-fullscreen all"; }
            Alt+Print { spawn-sh "noctalia msg screenshot-window"; }
            Ctrl+Print { spawn-sh "noctalia msg screenshot-region --annotate"; }

            // Media controls
            Ctrl+F9 { spawn "${media}" "previous"; }
            Ctrl+F10 { spawn "${media}" "play-pause"; }
            Ctrl+F11 { spawn "${media}" "next"; }

            // Function keys; these also work while the screen is locked.
            XF86AudioRaiseVolume allow-when-locked=true { spawn-sh "noctalia msg volume-up"; }
            XF86AudioLowerVolume allow-when-locked=true { spawn-sh "noctalia msg volume-down"; }
            XF86MonBrightnessUp allow-when-locked=true { spawn-sh "noctalia msg brightness-up"; }
            XF86MonBrightnessDown allow-when-locked=true { spawn-sh "noctalia msg brightness-down"; }
            XF86KbdBrightnessUp allow-when-locked=true { spawn-sh "noctalia msg keyboard-backlight-up"; }
            XF86KbdBrightnessDown allow-when-locked=true { spawn-sh "noctalia msg keyboard-backlight-down"; }
            XF86KbdLightOnOff allow-when-locked=true { spawn-sh "noctalia msg keyboard-backlight-toggle"; }
            XF86AudioMute allow-when-locked=true { spawn-sh "noctalia msg volume-mute"; }
            XF86AudioMicMute allow-when-locked=true { spawn-sh "noctalia msg mic-mute"; }
            Ctrl+Shift+Alt+M allow-when-locked=true { spawn-sh "noctalia msg mic-mute"; }
            XF86AudioPlay allow-when-locked=true { spawn "${media}" "play-pause"; }
            XF86AudioPause allow-when-locked=true { spawn "${media}" "play-pause"; }
            XF86AudioNext allow-when-locked=true { spawn "${media}" "next"; }
            XF86AudioPrev allow-when-locked=true { spawn "${media}" "previous"; }
        }
      '';
    }
  );
}
