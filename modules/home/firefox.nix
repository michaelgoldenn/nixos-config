{ flake, pkgs, ... }:
let
  inherit (flake) config inputs;
  inherit (inputs) self;
in
{
  dconf.settings = {
    "org/gnome/shell" = {
      favorite-apps = ["firefox.desktop"];
    };
  };
  programs.firefox = {
    enable = true;
    profiles.default = {
      id = 0;
      name = "default";
    };
  };
}