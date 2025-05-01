{pkgs, ...}: {
  networking.wg-quick.interfaces = let
    oliver_server_ip = "casptech.net";
    michael_server_ip = "";
  in {
    oliver-server = {
      # IP address of this machine in the *tunnel network*
      address = ["10.10.10.7/32"];
      dns = ["10.6.24.1" "10.10.10.1"];
      autostart = false;
      # To match firewall allowedUDPPorts (without this wg
      # uses random port numbers).
      listenPort = 51820;

      # Path to the private key file.
      privateKeyFile = "/etc/nixos/modules/nixos/oliver-server.private.key";
      peers = [
        {
          publicKey = "50Wn74uprGinf0UmHxayezL4JBBZph/IbipNejyi+ic=";
          allowedIPs = ["10.6.24.0/24"];
          endpoint = "${oliver_server_ip}:51820";
          persistentKeepalive = 25;
        }
      ];
    };
/*     michaels-server = {
      address = ["10.30.0.10/32"];
      dns = "1.1.1.1";
      privateKeyFile = "/etc/nixos/modules/nixos/michael-server.private.key";
      peers = [{
        publicKey = "";
        allowedIPs = ["0.0.0.0/0" "::/0"];
        endpoint = "${oliver_server_ip}:51820";
        persistentKeepalive = 25;
      }];
    }; */
  };
}
