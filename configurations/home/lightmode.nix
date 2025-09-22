{ flake, pkgs, ... }:
let
  inherit (flake) inputs;
  inherit (inputs) self;
in
{
  imports = [
    self.homeModules.default
  ];

  # Defined by /modules/home/me.nix
  # And used all around in /modules/home/*
  me = {
    username = "lightmode";
    fullname = "Light Mode";
    email = "";
  };

  cliTools.enable = true;
  vscode.enable = true;
  shell.default = "nushell"; # defined in modules/home/cli/terminal/default.nix
  theme = {
    name = "catppuccin-latte";
    polarity = "light";
    image = pkgs.fetchurl {
      url = "https://raw.githubusercontent.com/orangci/walls/refs/heads/master/clouds-3.jpg";
      sha256 = "sha256-zeRVRll2H9744n/InnNS+ImDr31JL3p6S4QdqyTk548=";
    };
  };

  home.stateVersion = "24.11";
}
