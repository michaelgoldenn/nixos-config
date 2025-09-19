{
  imports = [
    ./gnome.nix
    ./stylix.nix # commented out for now as it was causing issues. This means we only have Home Manager config but that's good enough for now
  ];
  services.xserver.enable = true;
}
