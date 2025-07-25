# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).
{
  config,
  pkgs,
  lib,
  ...
}:
{
  imports = [
    # Include the results of the hardware scan.
    ./hardware-configuration.nix
  ];

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "umbriel"; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Enable networking
  #networking.networkmanager.enable = true;

  # Set your time zone.
  time.timeZone = "America/New_York";

  # Enable the X11 windowing system.
  services.xserver.enable = true;

  # Workaround for GNOME autologin: https://github.com/NixOS/nixpkgs/issues/103746#issuecomment-945091229
  systemd.services."getty@tty1".enable = false;
  systemd.services."autovt@tty1".enable = false;

  # Configure keymap in X11
  services.xserver.xkb = {
    layout = "us";
    variant = "";
  };

  # Enable CUPS to print documents.
  services.printing.enable = true;

  # Enable tlp to limit battery
  services.power-profiles-daemon.enable = false;
  services.tlp = {
    enable = true;

    settings = {
      ## 1 – Battery-charge
      START_CHARGE_THRESH_BAT0 = 75;
      STOP_CHARGE_THRESH_BAT0 = 80;
      START_CHARGE_THRESH_BAT1 = 75;
      STOP_CHARGE_THRESH_BAT1 = 80;

      ## 2 – CPU: keep clocks low when on battery
      CPU_SCALING_GOVERNOR_ON_BAT = "powersave";
      CPU_ENERGY_PERF_POLICY_ON_BAT = "power"; # intel_pstate / amd-pstate
      CPU_MIN_PERF_ON_BAT = 0; # %
      CPU_MAX_PERF_ON_BAT = 30; # cap bursty boosts

      ## 3 – PCIe & USB runtime power management
      PCIE_ASPM_ON_BAT = "powersave";
      RUNTIME_PM_ON_BAT = "auto";
      USB_AUTOSUSPEND = 1; # 1 = enable for everything
      USB_BLACKLIST = "1-1"; # optional: keep the built-in keyboard alive

      ## 4 – Wi-Fi + Bluetooth
      WIFI_PWR_ON_BAT = 3; # 1–5, higher = more aggressive saving
      DEVICES_TO_DISABLE_ON_BAT = "bluetooth";

      ## 5 – Disks & audio
      DISK_APM_LEVEL_ON_BAT = "128 128"; # gentle head-parking for every drive
      SOUND_POWER_SAVE_ON_BAT = 1; # autosuspend the codec after 1 s

      ## 6 – Make the “battery” profile the default even if AC is detected
      #TLP_DEFAULT_MODE = "BAT"; # requires TLP ≥ 1.5
    };
  };
  # Enable sound with pipewire.
  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    # If you want to use JACK applications, uncomment this
    #jack.enable = true;

    # use the example session manager (no others are packaged yet so this is enabled by default,
    # no need to redefine it in your config for now)
    #media-session.enable = true;
  };

  # Enable touchpad support (enabled default in most desktopManager).
  # services.xserver.libinput.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.michael = {
    isNormalUser = true;
    description = "michael";
    extraGroups = [
      "networkmanager"
      "wheel"
      "libvirtd"
    ];
    packages = with pkgs; [ ];
  };

  mySystem = {
    vr.enable = lib.mkForce true;
    lutris.enable = true;
    services = {
      open-webui.enable = true;
    };
    DE = {
      gnome.enable = true;
      hyprland.enable = false;
    };
  };

  # Install firefox.
  programs.firefox.enable = true;

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    vulkan-tools
    vulkan-headers
    vulkan-validation-layers
    xorg.libxcb
    libva-utils
  ];

  environment.sessionVariables = {
    FLAKEREF = "/etc/nixos"; # for nh
  };

  ## gpu stuff
  # Enable OpenGL
  hardware.graphics = {
    enable = true;
    extraPackages = with pkgs; [
      # 64‑bit VA‑API libs
      intel-media-driver # modern “iHD” driver (Gen 9 → Arc)
      intel-vaapi-driver # legacy “i965” driver – still handy for Firefox
      libvdpau-va-gl # optional VDPAU→VAAPI bridge
    ];
    extraPackages32 = with pkgs.pkgsi686Linux; [
      intel-media-driver # 32‑bit libs for Steam / ALVR
      intel-vaapi-driver
    ];
  };
  # Load nvidia driver for Xorg and Wayland
  services.xserver.videoDrivers = [ "nvidia" ];
  hardware.nvidia = {
    # Modesetting is required.
    modesetting.enable = true;

    # Nvidia power management. Experimental, and can cause sleep/suspend to fail.
    # Enable this if you have graphical corruption issues or application crashes after waking
    # up from sleep. This fixes it by saving the entire VRAM memory to /tmp/ instead
    # of just the bare essentials.
    powerManagement.enable = true;

    # Fine-grained power management. Turns off GPU when not in use.
    # Experimental and only works on modern Nvidia GPUs (Turing or newer).
    powerManagement.finegrained = true;

    # Use the NVidia open source kernel module (not to be confused with the
    # independent third-party "nouveau" open source driver).
    # Support is limited to the Turing and later architectures. Full list of
    # supported GPUs is at:
    # https://github.com/NVIDIA/open-gpu-kernel-modules#compatible-gpus
    # Only available from driver 515.43.04+
    # Currently alpha-quality/buggy, so false is currently the recommended setting.
    open = false;

    # Enable the Nvidia settings menu,
    # accessible via `nvidia-settings`.
    nvidiaSettings = true;

    # Optionally, you may need to select the appropriate driver version for your specific GPU.
    package = config.boot.kernelPackages.nvidiaPackages.beta;

    # Enable Prime to handle integrated graphics switching
    prime = {
      #sync.enable = true;
      offload = {
        enable = true;
        enableOffloadCmd = true;
      };
      # Make sure to use the correct Bus ID values for your system!
      intelBusId = "PCI:0:2:0";
      nvidiaBusId = "PCI:1:0:0";
    };
  };
  environment.sessionVariables.LIBVA_DRIVER_NAME = "iHD"; # pick the modern driver

  services.xserver.displayManager.sessionCommands = ''
    ${lib.getBin pkgs.xorg.xrandr}/bin/xrandr --setprovideroutputsource 2 0
  '';
  system.stateVersion = "24.05"; # Did you read the comment?
}
