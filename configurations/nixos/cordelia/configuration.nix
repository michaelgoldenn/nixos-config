# for the cordelia system
{
  config,
  modulesPath,
  pkgs,
  lib,
  ...
}:
{
  imports = [
    ./hardware-configuration.nix
    (modulesPath + "/virtualisation/proxmox-lxc.nix")
  ];
  # custom modules
  syncthing = {
    enable = true;
    deviceName = "cordelia"; # Must match the key in syncthingDevices

    folders = {
      obsidian-vault = {
        path = "/home/michael/Documents/obsidian-vault";
        devices = [
          "ophelia"
          "titania"
          "umbriel"
        ];
      };
      making-games = {
        path = "/home/michael/projects/making-games/";
        devices = [
          "titania"
          "umbriel"
        ];
      };
    };
  };

  nix.settings = {
    sandbox = false;
  };
  networking.hostName = "cordelia";
  nixpkgs.config.allowUnfree = true;

  # proxmox things
  proxmoxLXC = {
    manageNetwork = false;
    privileged = true;
  };
  services.fstrim.enable = false; # Let Proxmox host handle fstrim

  # ssh things
  security.pam.services.sshd.allowNullPassword = true;
  services.openssh = {
    enable = true;
    openFirewall = true;
    settings = {
      PermitRootLogin = "yes";
      PasswordAuthentication = true;
    };
  };
  time.timeZone = "America/New_York";

  # Cache DNS lookups to improve performance
  services.resolved = {
    extraConfig = ''
      Cache=true
      CacheFromLocalhost=true
    '';
  };
  system.stateVersion = "25.05";
}
