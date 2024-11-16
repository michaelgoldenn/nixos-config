{ pkgs, ... }:
{
  home-manager.users.michael = {
    dconf.settings = {
      "org/gnome/shell" = {
        favorite-apps = ["firefox.desktop"]
      }
    };
  };
  programs.firefox = {
    enable = true;
  };
}