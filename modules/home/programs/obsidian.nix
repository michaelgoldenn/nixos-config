{ flake, pkgs, ... }:
let
  inherit (flake) config inputs;
  inherit (inputs) self;
in
{
  programs.obsidian = {
    enable = true;
    vaults.test-vault = {
      enable = true;
      path = "~/Documents/home-manager-test";
    };
  };
}