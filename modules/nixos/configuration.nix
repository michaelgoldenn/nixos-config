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
  users.users.michael = {
    isNormalUser = true;
    description = "michael";
    extraGroups = [ "networkmanager" "wheel" ];
    packages = with pkgs; [];
    shell = pkgs.nushell;
  };

  swapDevices = [
    {
      device = "/swapfile";
      size = 16384; # 16GB swap file
    }
  ];

  environment.gnome.excludePackages = with pkgs; [
    gnome-console
    gnome-keyring
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
  };
  nixpkgs.config.permittedInsecurePackages = [
    "electron-27.3.11" # need this for logseq >:( delete later
  ];
  environment.systemPackages = with pkgs; [
    signal-desktop
    libreoffice
    nushell
    samba
    git
    git-lfs
    libsecret
    lshw
    toybox
    nvtopPackages.full
    # boy oh boy I sure do love my CLI improvements
    # eza
    fd
    vesktop # wayland screen share is broken on anything but vesktop :(
    piper
    libratbag
    networkmanager-openvpn
    inputs.ghostty.packages.x86_64-linux.default
    logseq
    nix-output-monitor
    openssl
    open-webui
  ];
  environment.shells = with pkgs; [ nushell ];
  services.ratbagd.enable = true;
  
  programs.nix-ld.enable = true; # I'll run any executable I want, thank you very much
  services.xserver.excludePackages = [ pkgs.xterm ]; # I don't want xterm

  systemd.services.nbfc_service = {
    enable = true;
    path = [pkgs.kmod];
  };
  
  # enable networking
  networking = {
    networkmanager = {
      enable = true;
      plugins = with pkgs; [
        networkmanager-openvpn
      ];
    };
  };

  # Select internationalisation properties.
  i18n = {
    defaultLocale = "en_US.UTF-8";
    supportedLocales = [ "en_US.UTF-8/UTF-8" "nl_NL.UTF-8/UTF-8" ];
    extraLocaleSettings = {
      LC_ADDRESS = "en_US.UTF-8";
      LC_IDENTIFICATION = "en_US.UTF-8";
      LC_MEASUREMENT = "en_US.UTF-8";
      LC_MONETARY = "en_US.UTF-8";
      LC_NAME = "en_US.UTF-8";
      LC_NUMERIC = "en_US.UTF-8";
      LC_PAPER = "en_US.UTF-8";
      LC_TELEPHONE = "en_US.UTF-8";
      LC_TIME = "en_US.UTF-8";
    };
  };

  # import nur
  nixpkgs.config.packageOverrides = pkgs: {
    nur = import inputs.nur {
      inherit pkgs;
      nurpkgs = pkgs;
    };
  };

#  programs.nautilus-open-any-terminal = {
#    enable = true;
#    terminal = "foot";
#  };

  environment = {
    sessionVariables = {
      NAUTILUS_4_EXTENSION_DIR = lib.mkForce "${pkgs.nautilus-python}/lib/nautilus/extensions-4";
      FLAKE = "/etc/nixos";
    };
    pathsToLink = [
      "/share/nautilus-python/extensions"
    ];
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
