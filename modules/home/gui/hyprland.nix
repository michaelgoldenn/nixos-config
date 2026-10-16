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

  config = lib.mkIf config.hyprland.enable {
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
        };
        wallpaper.directory = "${config.home.homeDirectory}/Pictures/Wallpapers";
      };
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
          "float on, match:class ^dev\\.noctalia\\.Noctalia$"
          "size 1080 920, match:class ^dev\\.noctalia\\.Noctalia$"
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
          "$mod, D, exec, noctalia msg panel-toggle launcher"
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
