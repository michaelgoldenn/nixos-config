{ pkgs, ...}:
{
  dconf = {
    enable = true;
    settings = {
      "org/gnome/desktop/interface".clock-format = "12h";
      #"org/gtk/settings/file-chooser".clock-format = "12h";
      "org/gnome/desktop/interface".color-scheme = "prefer-dark";
      "org/gnome/shell" = {
        favorite-apps = ["firefox.desktop" "code.desktop" "vesktop.desktop"];
      };
      "org/gnome/settings-daemon/plugins/media-keys" = {
        media = ["<Shift><Control><Alt>q"]; # opens media player
        next = ["<Shift><Control><Alt>Right"];
        play = ["<Shift><Control><Alt>space"];
        previous = ["<Shift><Control><Alt>Left"];
        down = ["<Shift><Control><Alt>Down"];
        up = ["<Shift><Control><Alt>Up"];
      };
    };
  };
}