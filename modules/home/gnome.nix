{ ... }:
{
  dconf = {
    enable = true;
    settings = {
      ## Interface
      "org/gnome/desktop/interface".clock-format = "12h";
      "org/gnome/shell" = {
        favorite-apps = ["firefox.desktop" "code.desktop" "discord.desktop" "spotify.desktop" "app.bluebubbles.BlueBubbles.desktop" "org.gnome.Console.desktop"];
      };
      "org/gnome/settings-daemon/plugins/media-keys" = {
        media = ["<Shift><Control><Alt>q"]; # opens media player
        next = ["<Shift><Control><Alt>Right"];
        play = ["<Shift><Control><Alt>space"];
        previous = ["<Shift><Control><Alt>Left"];
        down = ["<Shift><Control><Alt>Down"];
        up = ["<Shift><Control><Alt>Up"];
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
        dynamic-workspaces = true;
        workspaces-only-on-primary = false;
        edge-tiling = true; # Dragging a window near the edge of the screen will resize it
      };
      "org/gnome/shell/app-switcher".current-workspace-only = true;
    };
  };
}