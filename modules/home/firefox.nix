{ pkgs, ... }:
{
  home-manager.users.nixos = {
    dconf.settings = {
      "org/gnome/shell" = {
        favorite-apps = ["firefox.desktop"];
      };
    };
  };
  programs.firefox = {
    enable = true;
  };
}