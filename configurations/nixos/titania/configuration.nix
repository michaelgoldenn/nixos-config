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
          "umbriel"
          "ophelia"
        ];
      };
      making-games = {
        path = "/home/michael/projects/making-games/";
        devices = [ "umbriel" ];
      };
    };
  };
  gui.enable = true;
  suspend.enable = false;
  grub.enable = true;

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

  # lets you use printers
  services.printing.enable = true;

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
    # Nvidia power management. Can cause sleep/suspend to not wake up.
    # But disabling can lead to weird artifacts. For titania both happen so I just don't let it suspend
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
    package = config.boot.kernelPackages.nvidiaPackages.stable;
  };

  environment.systemPackages = with pkgs; [
    networkmanager-openvpn
    openvpn
  ];

  # DO NOT touch this unless you fully understand the implications.
  # It's not updating your system, do `nix flake update` for that.
  # it does a bunch of other things that can cause problems
  system.stateVersion = "24.05"; # Did you read the comment?

}
