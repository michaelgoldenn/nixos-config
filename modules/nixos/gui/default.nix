{
  imports = [
    ./stylix.nix # commented out for now as it was causing issues. This means we only have Home Manager config but that's good enough for now
    ./system-packages.nix
    ./shell.nix
    ./DEs
  ];
  services.xserver.enable = true;
}
