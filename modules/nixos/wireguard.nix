{ pkgs, ... }:

let
  # keep the endpoint host in one place
  server_ip = "casptech.net";
in
{
  # open the same port that wg-quick implicitly used
  networking.firewall.allowedUDPPorts = [ 51820 ];

  networking.wireguard.interfaces = {
    wg0 = {
      # address  →  ips
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

      /*
        wg-quick’s “DNS = …” is **not** part of the wireguard module.
        If you still want 10.6.24.1 and 10.10.10.1 to be used whenever the
        tunnel is up, choose one of these common patterns:

        ── systemd-networkd on the interface ─────────────────────────────
        useNetworkd = true;
        networkConfig.DNS             = [ "10.6.24.1" "10.10.10.1" ];
        networkConfig.DNSDefaultRoute = "yes";

        ── or set them globally ──────────────────────────────────────────
        # networking.nameservers = [ "10.6.24.1" "10.10.10.1" ];
      */
    };
  };
}
