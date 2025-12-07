# This is your nixos configuration.
# For home configuration, see /modules/home/*
{ flake, ... }:
{
  imports = [
    flake.inputs.self.nixosModules.common
    ./services
  ];
  nixpkgs.overlays = [
    flake.inputs.millennium.overlays.default
  ];
  services.openssh.enable = true;
  programs.nix-ld.enable = true; # enable nix ld for all PCs.
}
