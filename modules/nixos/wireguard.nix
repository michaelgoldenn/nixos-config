{pkgs, ...}: {
  networking.wg-quick.interfaces = let
    server_ip = "casptech.net";
  in {
    wg0 = {
      # IP address of this machine in the *tunnel network*
      address = [
        "10.10.10.7/32"
      ];

      # To match firewall allowedUDPPorts (without this wg
      # uses random port numbers).
      listenPort = 51820;

      # Path to the private key file.
      privateKeyFile = "./private.key";

      peers = [
        {
          publicKey = "50Wn74uprGinf0UmHxayezL4JBBZph/IbipNejyi+ic=";
          allowedIPs = ["10.6.24.0/24"];
          endpoint = "${server_ip}:51820";
          persistentKeepalive = 25;
        }
      ];
    };
  };
}
