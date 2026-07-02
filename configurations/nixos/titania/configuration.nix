# system-level configuration for titania machine
{
  config,
  pkgs,
  ...
}:
{
  imports = [
    ./hardware-configuration.nix
  ];

  # Michael's Custom Definitions - new configuration stuff I've added
  syncthing = {
    enable = true;
    deviceName = "titania"; # Must match the key in syncthingDevices

    folders = {
      obsidian-vault = {
        path = "/home/michael/Documents/obsidian-vault";
        devices = [
          "cordelia"
          "umbriel"
          "ophelia"
        ];
      };
      making-games = {
        path = "/home/michael/projects/making-games/";
        devices = [
          "cordelia"
          "umbriel"
        ];
      };
      ftl-multiverse = {
        path = "/home/michael/.local/share/FasterThanLight";
        devices = [
          "umbriel"
        ];
      };
      the-tunnel = {
        path = "/home/michael/the-tunnel";
        devices = [
          "umbriel"
        ];
      };
      obs-config = {
        path = "/home/michael/.config/obs-studio";
        devices = [
          "umbriel"
        ];
      };
    };
  };
  gui.enable = true;
  grub.enable = true;
  xremap.enable = true;
  vr.enable = true;

  # Enable networking
  networking = {
    networkmanager.enable = true;
    hostName = "titania";
  };
  # A bunch of me-specific stuff (time zone, language, keyboard, etc.)
  time.timeZone = "America/Detroit";
  i18n.defaultLocale = "en_US.UTF-8";
  i18n.extraLocaleSettings = {
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

  # Enable the X11 windowing system.
  services.xserver.enable = true;
  # Configure keymap in X11
  services.xserver.xkb = {
    layout = "us";
    variant = "";
  };

  services.avahi = {
    enable = true;
    nssmdns4 = true;
    openFirewall = true;
  };
  # lets you use printers
  services.printing = {
    enable = true;
    drivers = with pkgs; [
      cups-filters
      cups-browsed
    ];
  };

  # Enable sound with pipewire.
  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # graphics drivers
  services.xserver.videoDrivers = [ "nvidia" ];
  # Enable OpenGL and Vulkan
  hardware.graphics = {
    enable = true;
    enable32Bit = true;
  };
  hardware.nvidia = {
    # Modesetting is required.
    modesetting.enable = true;
    # Nvidia power management. Can cause sleep/suspend to not wake up. added a kernel param fix below
    powerManagement.enable = true;
    # Fine-grained power management. Turns off GPU when not in use.
    # Experimental and only works on modern Nvidia GPUs (Turing or newer).
    powerManagement.finegrained = false;
    # Use the NVidia open source kernel module
    # Full list of supported GPUs: https://github.com/NVIDIA/open-gpu-kernel-modules#compatible-gpus
    # Only available from driver 515.43.04+ and currently alpha-quality/buggy
    open = false;
    nvidiaSettings = true;
    # Optionally, you may need to select the appropriate driver version for your specific GPU.
    package = config.boot.kernelPackages.nvidiaPackages.legacy_580;
  };

  environment.systemPackages = with pkgs; [
    networkmanager-openvpn
    openvpn
  ];

  # DO NOT touch this unless you fully understand the implications.
  # It's not updating your system, do `nix flake update` for that.
  # it does a bunch of other things that can cause problems
  system.stateVersion = "24.05"; # Did you read the comment?

  # a whole bunch of kernel stuff to fix suspend not working
  boot.kernelParams = [
    "NVreg_TemporaryFilePath=/var/tmp"
  ];
  systemd.services.systemd-suspend.environment.SYSTEMD_SLEEP_FREEZE_USER_SESSIONS = "false";
  # also for fixing suspend. The gnome-suspend and gnome-resume only need to be used when gnome is enabled,
  # so at some point I should make it only enable when gnome is enabled.
  systemd.services."gnome-suspend" = {
    description = "Suspend gnome shell";
    before = [
      "systemd-suspend.service"
      "systemd-hibernate.service"
      "nvidia-suspend.service"
      "nvidia-hibernate.service"
    ];
    wantedBy = [
      "systemd-suspend.service"
      "systemd-hibernate.service"
    ];
    serviceConfig = {
      Type = "oneshot";
      ExecStart = "${pkgs.procps}/bin/pkill -f -STOP ${pkgs.gnome-shell}/bin/gnome-shell";
    };
  };

  systemd.services."gnome-resume" = {
    description = "Resume gnome shell";
    after = [
      "systemd-suspend.service"
      "systemd-hibernate.service"
      "nvidia-resume.service"
    ];
    wantedBy = [
      "systemd-suspend.service"
      "systemd-hibernate.service"
    ];
    serviceConfig = {
      Type = "oneshot";
      ExecStart = "${pkgs.procps}/bin/pkill -f -CONT ${pkgs.gnome-shell}/bin/gnome-shell";
    };
  };
}
