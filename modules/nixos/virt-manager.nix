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
        # Enable NAT
    extraCommands = ''
      iptables -t nat -A PREROUTING -p tcp --dport 8123 -j DNAT --to 192.168.122.99:8123
      iptables -t nat -A POSTROUTING -o virbr0 -j MASQUERADE
    '';
    extraStopCommands = ''
      iptables -t nat -D PREROUTING -p tcp --dport 8123 -j DNAT --to 192.168.122.99:8123 || true
      iptables -t nat -D POSTROUTING -o virbr0 -j MASQUERADE || true
    '';
  };
  networking.bridges.virbr0.interfaces = [ ];
}