{ config, modulesPath, pkgs, lib, ... }:
{
  imports = [ ./hardware-configuration.nix (modulesPath + "/virtualisation/proxmox-lxc.nix") ];
  home-manager.users = {
    server = import ../../home/server.nix;
    # michael is intentionally omitted
  };
  nix.settings = { sandbox = false; };  
  networking.hostName = "cordelia";
  nixpkgs.config.allowUnfree = true;
  proxmoxLXC = {
    manageNetwork = false;
    privileged = true;
  };
  security.pam.services.sshd.allowNullPassword = true;
  services.fstrim.enable = false; # Let Proxmox host handle fstrim
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
