{ config, pkgs, ... }:
{
  # TODO: Make it so it only runs this when using gnome
  config = {
    dconf = {
      enable = true;
      settings = {
        ## Interface
        "org.gnome.desktop.default-applications.terminal".exec = config.terminal.default;
        "org/gnome/desktop/interface".clock-format = "12h";
        "org/gnome/shell" = {
          favorite-apps = [
            "firefox.desktop"
            "code.desktop"
            "discord.desktop"
            "spotify.desktop"
            "foot.desktop"
          ];
        };
        "org/gnome/settings-daemon/plugins/media-keys" = {
          previous = [ "<Ctrl>F9" ];
          play = [ "<Ctrl>F10" ];
          next = [ "<Ctrl>F11" ];
          mic-mute = [ "<Shift><Control><Alt>m" ];
        };
        #"org/gnome/desktop/peripherals/touchpad".natural-scroll = false;
        "org/gnome/desktop/session".idle-delay = 600; # screen off after 10 mins
        "org/gnome/settings-daemon/plugins/power" = {
          power-button-action = "interactive";
          sleep-inactive-battery-type = "suspend";
          sleep-inactive-ac-type = "suspend";
          # seconds until auto-suspend
          sleep-inactive-ac-timeout = "900";
        };
        # disable the auto-lock which locks on screen off. Using a systemd script in the other gnome.nix
        # which locks when suspending rather than when screen off
        "org/gnome/desktop/screensaver".lock-enabled = false;
        "org/gnome/desktop/interface" = {
          show-battery-percentage = true;
          enable-hot-corners = false;
        };
        "org/gnome/mutter" = {
          #dynamic-workspaces = true; # any amount of workspaces, blank ones are removed
          workspaces-only-on-primary = false;
          edge-tiling = true; # Dragging a window near the edge of the screen will resize it
        };
        "org/gnome/shell/app-switcher".current-workspace-only = true;
        # Extensions
        "org/gnome/shell".disable-user-extensions = false;
        "org/gnome/shell".enabled-extensions = with pkgs.gnomeExtensions; [
          all-windows-saverestore-window-positions.extensionUuid
          # fuzzy-app-search.extensionUuid
          gsconnect.extensionUuid
          focused-window-d-bus.extensionUuid
          # color-picker.extensionUuid
          caffeine.extensionUuid
          space-bar.extensionUuid
        ];
      };
    };
    home.packages = with pkgs.gnomeExtensions; [
      focused-window-d-bus
      caffeine
      space-bar
    ];
  };
}
