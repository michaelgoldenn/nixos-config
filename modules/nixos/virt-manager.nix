{ flake, pkgs, ... }:
let
  inherit (flake) config inputs;
  inherit (inputs) self;
in
{
  virtualisation.libvirtd = {
    enable = true;
    qemuOvmf = true;
    qemu.runAsRoot = true;
  };
  programs.virt-manager.enable = true;
  networking.firewall = {
    allowedTCPPorts = [ 8123 ];
    checkReversePath = false;
  };
  networking.bridges.virbr0.interfaces = [ ];
}