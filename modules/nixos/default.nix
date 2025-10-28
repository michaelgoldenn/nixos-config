# This is your nixos configuration.
# For home configuration, see /modules/home/*
{ flake, ... }:
{
  imports = [
    flake.inputs.self.nixosModules.common
    ./services
  ];
  services.openssh.enable = true;
  programs.nix-ld.enable = true; # enable nix ld for all PCs.
}
