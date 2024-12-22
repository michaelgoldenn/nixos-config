{ flake, lib, config, pkgs, ... }:
let
  inherit (flake) inputs;
  inherit (inputs) self;

  hostConfigs = {
    mirandia = {
      bridgeInterfaces = [ "enp9s0" ];
      ipAddress = "192.168.1.132";
      needsBridge = true;  # Flag to indicate this host needs bridge config
    };
    titania = {
      needsBridge = false;  # This host doesn't need bridge config
    };
    umbriel = {
      needsBridge = false;  # This host doesn't need bridge config
    };
  };
  # Default configuration in case hostname isn't found
  defaultConfig = {
    bridgeInterfaces = [ ];
    ipAddress = "192.168.1.100";
    needsBridge = false;
  };

  # Get current host's config or fall back to default
  currentHost = hostConfigs.${config.networking.hostName} or defaultConfig;

in
lib.mkIf currentHost.needsBridge {
  virtualisation.libvirtd = {
    enable = true;
    qemuOvmf = true;
    qemu.runAsRoot = true;
  };

  programs.virt-manager.enable = true;
  networking = {
    bridges = {
      br0 = {
        interfaces = currentHost.bridgeInterfaces;
      };
    };

    interfaces.br0.ipv4.addresses = [{
      address = currentHost.ipAddress;
      prefixLength = 24;
    }];
    
    firewall = {
      allowedTCPPorts = [ 8123 ];
      checkReversePath = false;
    };
  };
}