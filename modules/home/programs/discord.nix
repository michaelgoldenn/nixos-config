{ pkgs, ... }:
{
  dconf.settings = {
    "org/gnome/shell" = {
      favorite-apps = ["vesktop.desktop"];
    };
  };
  home.packages = with pkgs; [
    vesktop
  ];
}