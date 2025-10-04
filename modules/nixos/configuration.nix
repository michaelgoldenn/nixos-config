# This is your nixos configuration.
# For home configuration, see /modules/home/*
{
  flake,
  pkgs,
  lib,
  config,
  ...
}:
let
  inherit (flake) inputs;
  inherit (inputs) self;
  ftlman = inputs.ftlman.packages.${pkgs.system}.default;
in
{
  # These users can add Nix caches.
  nix.settings.trusted-users = [
    "root"
    "michael"
  ];

  # Define users
  users.groups.docker.gid = 131; # Use NixOS's preferred GID
  users.users.michael = {
    isNormalUser = true;
    description = "michael";
    extraGroups = [
      "networkmanager"
      "wheel"
      "podman"
    ];
    packages = with pkgs; [ ];
    shell = pkgs.nushell;
  };

  swapDevices = [
    {
      device = "/swapfile";
      size = 16384; # 16GB swap file
    }
  ];

  services.openssh.enable = true;

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
  environment.systemPackages = with pkgs; [
    signal-desktop
    libreoffice
    nushell
    samba
    git
    git-lfs
    fossil
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
    nix-output-monitor
    openssl
    xorg.xhost
    #lmstudio
    ollama
    prusa-slicer
    p7zip-rar
    speedtest-rs
    claude-code
    alsa-lib
    #unityhub
    cargo-shear
    clockify
    nixfmt-rfc-style
    yazi
    cargo-generate
    lldb
    slipstream
    ftlman
    audacity
    glsl_analyzer
    clang
    clang-tools
    freetype
    winetricks
    protontricks

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
  services.tailscale.enable = true;

  programs.nix-ld.enable = true; # I'll run any executable I want, thank you very much
  services.xserver = {
    enable = true;
    excludePackages = [ pkgs.xterm ]; # I don't want xterm
  };

  systemd.services.nbfc_service = {
    enable = true;
    path = [ pkgs.kmod ];
  };

  # Select internationalisation properties.
  i18n = {
    defaultLocale = "en_US.UTF-8";
    supportedLocales = [
      "en_US.UTF-8/UTF-8"
      "nl_NL.UTF-8/UTF-8"
    ];
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
      syncthing.enable = true;
    };
  };

  home-manager.extraSpecialArgs = {
    inheritedConfig = config.mySystem;
  };

  programs.nautilus-open-any-terminal = {
    enable = true;
    terminal = "ghostty";
  };

  xdg.terminal-exec = {
    enable = true;
    settings = {
      default = [
        "kitty.desktop"
      ];
    };
  };

  # rebind caps lock to escape
  services.remap = {
    enable = true;
    capsToEsc = true;
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
    enable = true; # Make sure NetworkManager is enabled
    plugins = [ pkgs.networkmanager-openvpn ]; # Add OpenVPN plugin
    pia-vpn = {
      enable = true;
      usernameFile = "/run/secrets/pia/username";
      passwordFile = "/run/secrets/pia/password";
      # Optionally specify specific servers if you don't want all of them
      serverList = [
        "us-chicago"
        "swiss"
      ];
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
      # calibre file share
      9090
      2222
    ];
    allowedUDPPorts = [
      # localsend
      53317
      5000 # whoogle
      # Samba share
      445
      139
      # calibre file share
      9090
      2222
    ];
  };
}
