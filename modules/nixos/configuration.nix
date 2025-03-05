# This is your nixos configuration.
# For home configuration, see /modules/home/*
{ flake, pkgs, lib, config, ... }:

let
  inherit (flake) inputs;
  inherit (inputs) self;
in
{
  # These users can add Nix caches.
  nix.settings.trusted-users = [ "root" "michael" ];

  # Define users
  users.groups.docker.gid = 131;  # Use NixOS's preferred GID
  users.users.michael = {
    isNormalUser = true;
    description = "michael";
    extraGroups = [ "networkmanager" "wheel" "podman" ];
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
    fd
    comma # just run `, Package` to run a package.
    vesktop # wayland screen share is broken on anything but vesktop :(
    piper
    libratbag
    networkmanager-openvpn
    logseq
    nix-output-monitor
    openssl
    xorg.xhost
    lmstudio
    ollama
    prusa-slicer
    p7zip-rar
    speedtest-rs
    claude-code

    # python stuff, testing for project
    cudaPackages.cudatoolkit
    cudaPackages.cudnn
    cudaPackages.libcublas
    cudaPackages.libcurand
    cudaPackages.libcusolver
    cudaPackages.libcusparse
  ];
  environment.shells = with pkgs; [ nushell ];
  services.ratbagd.enable = true;
  
  programs.nix-ld.enable = true; # I'll run any executable I want, thank you very much
  services.xserver = {
    enable = true;
    excludePackages = [ pkgs.xterm ]; # I don't want xterm 
  };
  

  systemd.services.nbfc_service = {
    enable = true;
    path = [pkgs.kmod];
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


  nix.optimise.automatic = true; # automatically remove old/unused versions

  # lets me use docker :)
  virtualisation = {
    podman = {
      enable = true;
      dockerCompat = true;
      # For rootless containers
      defaultNetwork.settings.dns_enabled = true;
    };
  };

  mySystem = lib.mkDefault {
    lutris.enable = false;
    vr.enable = false;
    
    services = {
      whoogle.enable = false;
      syncthing = {
        enable = true;
        known_devices = {
          titania = {
            id = "Q4GJXVG-6JIJKWO-ALIV3BP-IVN6423-4V3MTCO-RRLP35U-WEDCFHT-MK7T3Q2";
            name = "titania";
          };
          umbriel = {
            id = "FMEVS7C-3VGJ2GF-OMYA3MW-CHQAZYC-EEHQ5Y4-CLX2FZH-7JB2LRJ-5UCZ3QP";
            name = "umbriel";
          };
          michaels-iphone = {
            id = "6R3DOKM-TZSDQZO-FIIBTQF-223PLHW-53KS22E-DZTFSQK-4FTYGT3-XSVBFAX";
            name = "michaels-iphone";
          };
        };
        obsidian_vault = {
          enable = true;
          devices = [ "titania" "umbriel" "michaels-iphone" ];
        };
        one_game_a_week = {
          enable = true;
          devices = [ "titania" "umbriel" ];
        };
      };
    };
  };

  home-manager.extraSpecialArgs = {
    inheritedConfig = config.mySystem;
  };

  programs.nautilus-open-any-terminal = {
    enable = true;
    terminal = "ghostty";
  };

  environment = {
    sessionVariables = {
      NAUTILUS_4_EXTENSION_DIR = lib.mkForce "${pkgs.nautilus-python}/lib/nautilus/extensions-4";
      FLAKE = "/etc/nixos";
    };
    pathsToLink = [
      "/share/nautilus-python/extensions"
    ];
  };

  # vpn
  networking.networkmanager = {
    enable = true;  # Make sure NetworkManager is enabled
    plugins = [ pkgs.networkmanager-openvpn ];  # Add OpenVPN plugin
    pia-vpn = {
      enable = true;
      usernameFile = "/run/secrets/pia/username";
      passwordFile = "/run/secrets/pia/password";
      # Optionally specify specific servers if you don't want all of them
      serverList = [ "us-chicago" "swiss" ];
    };
  };

  services.nginx.enable = true;
  networking = {
    domain = "localhost";
  };

  networking.firewall = { 
    allowedTCPPorts = [
      # localsend
      53317
      5000 # whoogle
      # Samba share
      445
      139
    ];
    allowedUDPPorts = [
      # localsend
      53317 
      5000 # whoogle
      # Samba share
      445
      139
    ];
  };
}
