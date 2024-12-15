{ flake, pkgs, ... }:
let
  inherit (flake) config inputs;
  inherit (inputs) self;
in
{
  home.packages = with pkgs; [
    vesktop
  ];
}