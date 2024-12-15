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

  # Define users
  users.users.michael = lib.mkDefault {
    isNormalUser = true;
    description = "michael";
    extraGroups = [ "networkmanager" "wheel" ];
    packages = with pkgs; [];
    #shell = pkgs.nushell;
  };

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
    nushell
  ];

  programs.nix-ld.enable = true; # I'll run any executable I want, thank you very much

  # import nur
  nixpkgs.config.packageOverrides = pkgs: {
    nur = import inputs.nur {
      inherit pkgs;
      nurpkgs = pkgs;
    };
  };

  networking.firewall = { 
    allowedTCPPorts = [
      # localsend
      53317
    ];
    allowedUDPPorts = [
      # localsend
      53317
    ];
  };
}
