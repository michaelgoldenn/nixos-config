# Binary caches, including sharing the Nix store between my own machines.
#
# Every host listed in `storeSharingHosts` below serves its own Nix store over
# HTTP (via Harmonia) and uses every *other* listed host as a substituter. So
# once a derivation has been built - or downloaded from upstream - on one
# machine, the others fetch it over the LAN instead of building or downloading
# it again. Hosts find each other over mDNS (`<hostname>.local`), so this needs
# no static IPs or DNS entries; they just have to be on the same network.
#
# Adding another machine:
#   1. `nix-store --generate-binary-cache-key <host>-1 priv.key pub.key`
#   2. `just sops`, and add the contents of priv.key under `nix-cache/<host>`
#   3. paste the contents of pub.key into `storeSharingHosts` below
{ config, lib, ... }:
let
  storeSharingHosts = {
    titania = "titania-1:Trp1EI8iU0FmQkkuIMOebfk/0ObQ+LhrlheeOfl1BLY=";
    umbriel = "umbriel-1:J6YhuNFVLCebZ8i4k+LtPTfuzE49TqQhT1dleGgsbbo=";
  };

  port = 5000;
  inherit (config.networking) hostName;
  sharesStore = storeSharingHosts ? ${hostName};
  peers = removeAttrs storeSharingHosts [ hostName ];
in
{
  config = lib.mkMerge [
    {
      nix.settings.substituters = [
        "https://nix-community.cachix.org"
      ];

      nix.settings.trusted-public-keys = [
        "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      ];
    }

    (lib.mkIf sharesStore {
      # --- serve this machine's store to the others ---
      sops.secrets."nix-cache/${hostName}" = {
        mode = "0400";
        owner = "root";
        group = "root";
      };

      services.harmonia.cache = {
        enable = true;
        # Everything this host serves is signed with its own key, which is what
        # lets the other machines trust it (see `trusted-public-keys` below).
        signKeyPaths = [ config.sops.secrets."nix-cache/${hostName}".path ];
        settings = {
          bind = "[::]:${toString port}";
          # cache.nixos.org advertises priority 40 and lower wins, so this makes
          # a machine on the LAN preferred over re-downloading from upstream.
          priority = 30;
        };
      };
      networking.firewall.allowedTCPPorts = [ port ];

      # Publish this host's address over mDNS so the other machines can resolve
      # `<hostname>.local`. Resolution itself needs nssmdns4.
      services.avahi = {
        enable = lib.mkDefault true;
        nssmdns4 = lib.mkDefault true;
        publish = {
          enable = true;
          addresses = true;
        };
      };

      # --- use the other machines' stores ---
      nix.settings = {
        substituters = lib.mapAttrsToList (peer: _: "http://${peer}.local:${toString port}") peers;
        trusted-public-keys = lib.attrValues peers;
        # A peer that is powered off or away from home should cost a rebuild a
        # couple of seconds, not stall it.
        connect-timeout = 5;
        # ...and if it can't be reached at all, build from source rather than
        # giving up.
        fallback = true;
      };
    })
  ];
}
