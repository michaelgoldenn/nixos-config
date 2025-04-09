{config, pkgs, ...}: {
  dconf = {
    enable = true;
    settings = {
      ## Interface
      "org.gnome.desktop.default-applications.terminal".exec = config.opt.terminal.default;
      "org/gnome/desktop/interface".clock-format = "12h";
      "org/gnome/shell" = {
        favorite-apps = ["firefox.desktop" "code.desktop" "discord.desktop" "spotify.desktop" "app.bluebubbles.BlueBubbles.desktop" "foot.desktop"];
      };
      "org/gnome/settings-daemon/plugins/media-keys" = {
        previous = ["<Ctrl>F9"];
        play = ["<Ctrl>F10"];
        next = ["<Ctrl>F11"];
        mic-mute = ["<Shift><Control><Alt>m"];
      };
      #"org/gnome/desktop/peripherals/touchpad".natural-scroll = false;
      "org/gnome/desktop/session".idle-delay = 600; # screen off after 10 mins
      "org/gnome/settings-daemon/plugins/power" = {
        power-button-action = "interactive";
        sleep-inactive-battery-type = "nothing";
        sleep-inactive-ac-type = "nothing";
      };
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
        gsconnect.extensionUuid
      ];
    };
  };
}
