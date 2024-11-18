{ pkgs, ...}:
{
  dconf = {
    enable = true;
    settings = {
      #"/org/gnome/desktop/interface/clock-format" = "12h";
      #"/org/gtk/settings/file-chooser/clock-format" = "12h";
      "org/gnome/desktop/interface".color-scheme = "prefer-dark";
    };
  };
}