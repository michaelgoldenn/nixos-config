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
        interfaces = [ "enp0s20u2c2" ]; # Replace with your actual interface name
      };
    };
    # Optional: If using DHCP
    interfaces.br0.ipv4.addresses = [{
          address = "192.168.1.132";
          prefixLength = 24;
        }];
    
    firewall = {
      allowedTCPPorts = [ 8123 ];
      checkReversePath = false;
    };
  };
}