{ flake, pkgs, ... }:
let
  inherit (flake) config inputs;
  inherit (inputs) self;
in
{
  dconf.settings = {
    "org/gnome/shell" = {
      favorite-apps = ["code.desktop"];
    };
  };
  programs.vscode = {
    enable = true;
  };
}