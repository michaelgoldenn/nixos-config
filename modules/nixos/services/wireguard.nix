{
  pkgs,
  lib,
  config,
  ...
}:
{
  sops.secrets = {
    "wireguard/titania-pub-key" = {
      mode = "0440";
      owner = config.users.users.michael.name;
    };
    "wireguard/titania-priv-key" = {
      mode = "0440";
      owner = config.users.users.michael.name;
    };
    "wireguard/umbriel-pub-key" = {
      mode = "0440";
      owner = config.users.users.michael.name;
    };
    "wireguard/umbriel-priv-key" = {
      mode = "0440";
      owner = config.users.users.michael.name;
    };
  };
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
        "titania" = config.sops.secrets."wireguard/titania-priv-key".path;
        "umbriel" = config.sops.secrets."wireguard/umbriel-priv-key".path;
      };
      currentAddress = addressMap.${hostname} or "10.10.10.100";
      currentPrivKey = privateKeyFiles.${hostname} or "";
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
            publicKey = "50Wn74uprGinf0UmHxayezL4JBBZph/IbipNejyi+ic=";
            allowedIPs = [ "10.6.24.0/24" ];
            endpoint = "${oliver_server_ip}:51820";
            persistentKeepalive = 25;
          }
        ];
      };
    };
}
