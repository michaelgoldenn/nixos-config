{
  imports = [
    ./localsend.nix
    ./DEs
    ./shell.nix
    ./stylix.nix # commented out for now as it was causing issues. This means we only have Home Manager config but that's good enough for now
    ./system-packages.nix
    ./vr.nix
    ./davinci_resolve.nix
  ];
  services.xserver.enable = true;
  # this is for calibre but it's a home-manager option and this needs to be in nixos:
  networking.firewall = {
    allowedTCPPorts = [ 9090 ];
    allowedUDPPorts = [ 9090 ];
  };
}
