{ flake, pkgs, ... }:
let
  inherit (flake) config inputs;
  inherit (inputs) self;
in
{
  virtualisation.libvirtd.enable = true;
  programs.virt-manager.enable = true;
  
}