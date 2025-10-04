{ pkgs, ... }:
{
  imports = [ ./pia-nm.nix ];
  # set up pia
  networking.networkmanager = {
    enable = true;
    plugins = [ pkgs.networkmanager-openvpn ]; # Add OpenVPN plugin
    pia-vpn = {
      enable = true;
      usernameFile = "/run/secrets/pia/username";
      passwordFile = "/run/secrets/pia/password";
      # Optionally specify specific servers if you don't want all of them
      serverList = [
        "us-chicago"
        "swiss"
      ];
    };
  };
}
