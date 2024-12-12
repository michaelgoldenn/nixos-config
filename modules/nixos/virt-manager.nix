{ flake, pkgs, ... }:
let
  inherit (flake) config inputs;
  inherit (inputs) self;
  primaryInterface = config.networkConfig.primaryInterface;
in
{
  virtualisation.libvirtd = {
    enable = true;
    qemuOvmf = true;
    qemu.runAsRoot = true;
  };
  programs.virt-manager.enable = true;
  
  networking = {
    bridges = {
      br0 = {
        interfaces = [ primaryInterface ];
      };
    };
    interfaces.br0.useDHCP = true;
    
    firewall = {
      allowedTCPPorts = [ 8123 ];
      checkReversePath = false;
    };
  };
}