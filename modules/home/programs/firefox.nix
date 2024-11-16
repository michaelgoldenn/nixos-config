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
    profiles = {
      michael = {
        id = 0;
        name = "michael";
        isDefault = true;
      };
    };
    # policy list: https://mozilla.github.io/policy-templates/
    policies = {

    };
  };
}