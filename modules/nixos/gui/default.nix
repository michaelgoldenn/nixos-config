{
  imports = [
    ./localsend.nix
    ./DEs
    ./shell.nix
    ./stylix.nix # commented out for now as it was causing issues. This means we only have Home Manager config but that's good enough for now
    ./system-packages.nix
    ./vr.nix
  ];
  services.xserver.enable = true;
}
