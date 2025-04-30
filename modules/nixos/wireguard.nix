{ lib, pkgs, ... }:

let
  server_ip = "casptech.net";
in
{
  # Enable WireGuard
  networking.firewall = {
    allowedUDPPorts = [51820];
    checkReversePath = false;
  };
  networking.wireguard.enable = true;
  networking.wireguard.interfaces = {
     #"wg0" is the network interface name. You can name the interface arbitrarily.
     wgl0 = {
      # Determines the IP address and subnet of the client's end of the tunnel interface.
      ips = [ "10.10.10.7/32" ];
      listenPort = 51820; # to match firewall allowedUDPPorts (without this wg uses random port numbers)
      #mtu = 1360;
      privateKeyFile = "/etc/nixos/modules/nixos/private.key";
      peers = [{
          # Public key of the server (not a file path).
          publicKey = "50Wn74uprGinf0UmHxayezL4JBBZph/IbipNejyi+ic=";
          # Forward all the traffic via VPN.
          allowedIPs = [ "10.6.24.0/24" ];
          # Or forward only particular subnets
          #allowedIPs = [ "10.100.0.1" "11.111.11.0/22" ];
          # Set this to the server IP and port.
          #name = "peer1";
          endpoint = "${server_ip}:51820";  #  ToDo: route to endpoint not automatically configured https://wiki.archlinux.org/index.php/WireGuard#Loop_routing https://discourse.nixos.org/t/solved-minimal-firewall-setup-for-wireguard-client/7577
          # Send keepalives every 25 seconds. Important to keep NAT tables alive.
          persistentKeepalive = 25;
        }
      ];
    }; # it’s not imperative but it does not know how to do it : sudo ip route add 11.111.11.111 via 192.168.1.11 dev wlo1 the ip adresse 11: external and 192: local.
  };
}
