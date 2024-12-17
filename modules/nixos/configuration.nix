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

  environment.gnome.excludePackages = with pkgs; [
    gnome-console
  ];

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
    samba
    git
    libsecret
  ];

  programs.nix-ld.enable = true; # I'll run any executable I want, thank you very much

  # import nur
  nixpkgs.config.packageOverrides = pkgs: {
    nur = import inputs.nur {
      inherit pkgs;
      nurpkgs = pkgs;
    };
  };

  # Create a script to automatically configure git credentials
systemd.user.services.git-credentials-setup = {
    description = "Setup Git Credentials with GitHub token";
    wantedBy = [ "default.target" ];
    after = [ "sops-nix.service" ];
    
    script = ''
      TOKEN=$(cat /run/secrets/github/obsidian)
      
      ${pkgs.git}/bin/git config --global credential.helper libsecret
      
      echo "url=https://github.com
      username=YOUR_GITHUB_USERNAME
      password=$TOKEN" | ${pkgs.git}/bin/git credential approve
    '';

    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
    };
  };

  networking.firewall = { 
    allowedTCPPorts = [
      # localsend
      53317

      # Samba share
      445
      139
    ];
    allowedUDPPorts = [
      # localsend
      53317

      # Samba share
      445
      139
    ];
  };
}
