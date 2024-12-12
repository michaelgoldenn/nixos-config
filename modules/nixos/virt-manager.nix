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
  
  # Bridge configuration
  networking = {
    bridges = {
      br0 = {
        interfaces = [ "enp4s0" ]; # Replace with your actual interface name
      };
    };
    # Optional: If using DHCP
    interfaces.br0.useDHCP = true;
    
    firewall = {
      allowedTCPPorts = [ 8123 ];
      checkReversePath = false;
    };
  };
}