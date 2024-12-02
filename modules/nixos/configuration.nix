# This is your nixos configuration.
# For home configuration, see /modules/home/*
{ flake, pkgs, lib, ... }:

let
  inherit (flake) inputs;
  inherit (inputs) self;
in
{
  # These users can add Nix caches.
  nix.settings.trusted-users = [ "root" "michael" ];

  services.openssh.enable = true;

  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true; # Open ports in the firewall for Steam Remote Play
    dedicatedServer.openFirewall = true; # Open ports in the firewall for Source Dedicated Server
  };
  
  services.flatpak = {
    enable = true;
    uninstallUnmanaged = true;
    remotes = [
      {
        name = "flathub";
        location = "https://dl.flathub.org/repo/flathub.flatpakrepo";
      }
    ];
    packages = [
    "app.bluebubbles.BlueBubbles"
    ];
  };
  environment.systemPackages = with pkgs; [
    signal-desktop
    libreoffice
    sops
  ];

  # import nur
  nixpkgs.config.packageOverrides = pkgs: {
    nur = import inputs.nur {
      inherit pkgs;
      nurpkgs = pkgs;
    };
  };
}
