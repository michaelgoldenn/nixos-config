{ flake, ... }:
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
    username = "michael";
    fullname = "Michael Golden";
    email = "Michael.Golden0278@gmail.com";
  };

  cliTools.enable = true;

  home.stateVersion = "24.11";
}
