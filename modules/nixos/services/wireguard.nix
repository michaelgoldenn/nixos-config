{
  pkgs,
  lib,
  config,
  ...
}:
{
  networking.wg-quick.interfaces =
    let
      oliver_server_ip = "casptech.net";

      # Get the hostname of the current machine
      hostname = config.networking.hostName;

      # Map hostnames to their respective WireGuard addresses
      addressMap = {
        "titania" = "10.10.10.7";
        "umbriel" = "10.10.10.17";
        # Add more hostnames and addresses as needed
      };

      # Get the address for the current hostname, with a fallback
      currentAddress = addressMap.${hostname} or "10.10.10.100";
    in
    {
      oliver-server = {
        # IP address of this machine in the *tunnel network*
        address = [ "${currentAddress}/32" ];
        dns = [
          "10.6.24.1"
          "10.10.10.1"
        ];
        autostart = false;
        # To match firewall allowedUDPPorts (without this wg
        # uses random port numbers).
        listenPort = 51820;

        # Path to the private key file.
        privateKeyFile = "/run/secrets/wireguard/titania-priv-key";
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
