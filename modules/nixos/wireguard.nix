{ lib, pkgs, ... }:

let
  # change once and it is reused everywhere
  serverHost = "casptech.net";
  # generate once with `uuidgen` (NM insists every profile has a UUID)
  wgUUID     = "ce1ba3ab-3cf8-4e7d-a9b7-734fff8a1f62";
in
{
  networking.firewall.allowedUDPPorts = [ 51820 ];
  networking.networkmanager.enable = true;
  networking.networkmanager.ensureProfiles = {
    profiles."wg0" = {
      connection = {
        id             = "wg0";
        uuid           = wgUUID;
        type           = "wireguard";
        interface-name = "wg0";     # keeps the kernel ifname nice
        autoconnect    = false;     # flip to true if you want auto-up
      };

      ipv4 = {                     # static tunnel address
        address1      = "10.10.10.7/32";
        method        = "manual";
        never-default = true;      # don’t override the normal default route
      };
      ipv6.method = "ignore";

      # --- interface settings --------------------------------------
      wireguard = {
        listen-port = 51820;
        private-key = "/etc/nixos/modules/nixos/private.key";
        private-key-flags = 2;     # tell NM that the key comes from an agent
      };

      /* --- peer (section name must contain the peer public key) ---- */
      "wireguard-peer.50Wn74uprGinf0UmHxayezL4JBBZph/IbipNejyi+ic=" = {
        endpoint            = "${serverHost}:51820";
        allowed-ips         = "10.6.24.0/24;";   # semicolon is required
        persistent-keepalive = 25;
      };
    };
  };
}
