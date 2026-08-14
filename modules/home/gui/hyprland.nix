## Hyprland user-level configuration.
## The compositor itself, its portals and the system packages it needs are set up
## on the NixOS side in /modules/nixos/gui/DEs/hyprland. This module only writes
## ~/.config/hypr/hyprland.conf, so it follows whichever specialisation is booted.
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

  config = lib.mkIf config.hyprland.enable {
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

        layerrule = [
          "blur on, match:namespace noctalia-background-.*$"
          "blur_popups on, match:namespace noctalia-background-.*$"
          "ignore_alpha 0.5, match:namespace noctalia-background-.*$"
        ];

        input = {
          kb_layout = "us";
          follow_mouse = 1;
          touchpad.natural_scroll = true;
        };

        gesture = "3, horizontal, workspace";

        bind = [
          "$mod, Return, exec, $terminal"
          "$mod, C, killactive"
          "$mod, M, exit"
          "$mod, V, togglefloating"
          "$mod, F, fullscreen"
          "$mod, D, exec, qs -c noctalia-shell ipc call launcher toggle"
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

        bindm = [
          "$mod, mouse:272, movewindow"
          "$mod, mouse:273, resizewindow"
        ];
      };
    };
  };
}
