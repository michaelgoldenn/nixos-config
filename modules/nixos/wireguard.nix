{ pkgs, ... }:

let
  server_ip = "casptech.net";
in
{
  networking.firewall.allowedUDPPorts = [ 51820 ];

  networking.wireguard.interfaces = {
    wg0 = {
      ips = [ "10.10.10.7/32" ];
      listenPort     = 51820;
      privateKeyFile = "/etc/nixos/modules/nixos/private.key";
      peers = [
        {
          publicKey           = "50Wn74uprGinf0UmHxayezL4JBBZph/IbipNejyi+ic=";
          allowedIPs          = [ "10.6.24.0/24" ];
          endpoint            = "${server_ip}:51820";
          persistentKeepalive = 25;
        }
      ];
    };
  };
}
