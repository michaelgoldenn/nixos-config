## ProtonVPN as NetworkManager WireGuard connections, so they can be toggled from noctalia's
## network tab (or `nmcli connection up "ProtonVPN - US"`) without the proton-vpn app.
##
## Adding a server:
# 1. account.protonvpn.com -> Downloads -> WireGuard configuration. Pick the server, turn
#    "NetShield" etc. how you like, then "Create". Each config gets its own key pair.
# 2. `just sops` and add the config's `PrivateKey` under `protonvpn/<name>` (name = the key below)
# 3. Add an entry below with the config's peer `PublicKey` and `Endpoint` (those aren't secret)
# 4. Rebuild. The connection shows up as "ProtonVPN - <label>"
{
  lib,
  config,
  ...
}:
let
  servers = {
    us = {
      label = "US";
      publicKey = "E85BuwGKhFpT//ZiPpNc3VkG6Bu14Ert8vgt760BlCY=";
      endpoint = "66.234.152.34:51820";
    };
  };

  envVar = name: "PROTONVPN_${lib.toUpper name}_KEY";
in
{
  sops.secrets = lib.mapAttrs' (
    name: _:
    lib.nameValuePair "protonvpn/${name}" {
      mode = "0400";
    }
  ) servers;

  # ensureProfiles substitutes $VARS from this file, which keeps the private keys out of the store
  sops.templates."protonvpn.env" = lib.mkIf (servers != { }) {
    content = lib.concatLines (
      lib.mapAttrsToList (
        name: _: "${envVar name}=${config.sops.placeholder."protonvpn/${name}"}"
      ) servers
    );
  };

  networking.networkmanager.ensureProfiles = lib.mkIf (servers != { }) {
    environmentFiles = [ config.sops.templates."protonvpn.env".path ];
    profiles = lib.mapAttrs' (
      name: server:
      lib.nameValuePair "protonvpn-${name}" {
        connection = {
          id = "ProtonVPN - ${server.label}";
          type = "wireguard";
          # interface names are capped at 15 chars
          interface-name = "pvpn-${name}";
          autoconnect = false;
        };
        wireguard.private-key = "$" + envVar name;
        "wireguard-peer.${server.publicKey}" = {
          inherit (server) endpoint;
          allowed-ips = "0.0.0.0/0;::/0;";
        };
        # Same addresses/DNS for every server in Proton's configs
        ipv4 = {
          method = "manual";
          address1 = "10.2.0.2/32";
          dns = "10.2.0.1;";
          # route all DNS through the tunnel instead of also asking the LAN's resolver
          dns-search = "~.;";
          dns-priority = -1500;
        };
        ipv6 = {
          method = "manual";
          address1 = "2a07:b944::2:2/128";
          dns = "2a07:b944::2:1;";
          dns-search = "~.;";
          dns-priority = -1500;
        };
      }
    ) servers;
  };

  # With a full tunnel the reply packets arrive on the wg interface while the default route
  # points elsewhere, which the strict reverse path check drops
  networking.firewall.checkReversePath = lib.mkIf (servers != { }) "loose";
}
