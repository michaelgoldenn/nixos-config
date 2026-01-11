{
  pkgs,
  lib,
  config,
  ...
}:
{
  networking.wg-quick.interfaces =
    let
      # Map hostnames to their respective WireGuard addresses
      oliver_server_ip = "casptech.net";
      hostname = config.networking.hostName;
      addressMap = {
        "titania" = "10.10.10.7";
        "umbriel" = "10.10.10.17";
      };
      privateKeyFiles = {
        "titania" = "/run/secrets/wireguard/titania-priv-key";
        "umbriel" = "/run/secrets/wireguard/umbriel-priv-key";
      };
      publicKeyFiles = {
        "titania" = "/run/secrets/wireguard/titania-pub-key";
        "umbriel" = "/run/secrets/wireguard/umbriel-pub-key";
      };
      currentAddress = addressMap.${hostname} or "10.10.10.100";
      currentPrivKey = privateKeyFiles.${hostname} or "";
      currentPubKey = publicKeyFiles.${hostname} or "";
    in
    {
      oliver-server = {
        address = [ "${currentAddress}/32" ];
        dns = [
          "10.6.24.1"
          "10.10.10.1"
        ];
        autostart = false;
        # matches firewall allowedUDPPorts (without this wg uses random port numbers).
        listenPort = 51820;
        # Path to the private key file.
        privateKeyFile = currentPrivKey;
        peers = [
          {
            publicKey = currentPubKey;
            allowedIPs = [ "10.6.24.0/24" ];
            endpoint = "${oliver_server_ip}:51820";
            persistentKeepalive = 25;
          }
        ];
      };
    };
}
