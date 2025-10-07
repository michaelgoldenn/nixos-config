{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.syncthing;
  
  # Centralized device registry
  syncthingDevices = {
    umbriel = "ABC1234-DEF5678-GHI9012-JKL3456-MNO7890-PQR1234-STU5678-VWX9012";
    titania = "V2RH23M-O6KH6M4-QE3LHTR-SZXNO4G-ZVDL4C7-Y4R55XF-DFQY3XO-YBNGVA5";
    # Add more devices here as needed
    # oberon = "XYZ9876-...";
  };
  
  # Build device configuration from all devices defined across folders
  allDevices = unique (flatten (
    mapAttrsToList (folderName: folderCfg: folderCfg.devices) cfg.folders
  ));
  
  # Create device configs using the centralized registry
  deviceConfigs = listToAttrs (map (deviceName: {
    name = deviceName;
    value = {
      id = syncthingDevices.${deviceName} or (throw "Device ID for '${deviceName}' not defined in syncthingDevices registry");
    };
  }) allDevices);
  
  # Get this machine's device ID from the registry
  thisDeviceId = syncthingDevices.${cfg.deviceName} or (throw "Device '${cfg.deviceName}' not found in syncthingDevices registry");
  
  # Create folder configs
  folderConfigs = mapAttrs (folderName: folderCfg: {
    path = folderCfg.path;
    devices = folderCfg.devices;
    ignorePerms = folderCfg.ignorePerms;
    type = folderCfg.type;
    rescanIntervalS = folderCfg.rescanIntervalS;
    fsWatcherEnabled = folderCfg.fsWatcherEnabled;
    versioning = folderCfg.versioning;
  }) cfg.folders;

in {
  options.syncthing = {
    enable = mkEnableOption "declarative Syncthing configuration";
    
    user = mkOption {
      type = types.str;
      default = "syncthing";
      description = "User account under which Syncthing runs";
    };
    
    group = mkOption {
      type = types.str;
      default = "syncthing";
      description = "Group under which Syncthing runs";
    };
    
    deviceName = mkOption {
      type = types.str;
      default = config.networking.hostName;
      description = "The device name for this machine (must match an entry in syncthingDevices)";
    };
    
    folders = mkOption {
      type = types.attrsOf (types.submodule {
        options = {
          path = mkOption {
            type = types.str;
            description = "Path to the folder to sync";
          };
          
          devices = mkOption {
            type = types.listOf types.str;
            default = [];
            description = "List of device names to share this folder with";
          };
          
          ignorePerms = mkOption {
            type = types.bool;
            default = true;
            description = "Whether to ignore permission changes";
          };
          
          type = mkOption {
            type = types.enum [ "sendreceive" "sendonly" "receiveonly" ];
            default = "sendreceive";
            description = "Folder type";
          };
          
          rescanIntervalS = mkOption {
            type = types.int;
            default = 3600;
            description = "Rescan interval in seconds";
          };
          
          fsWatcherEnabled = mkOption {
            type = types.bool;
            default = true;
            description = "Enable filesystem watcher for instant sync";
          };
          
          versioning = mkOption {
            type = types.nullOr (types.submodule {
              options = {
                type = mkOption {
                  type = types.enum [ "simple" "trashcan" "staggered" "external" ];
                  description = "Versioning type";
                };
                params = mkOption {
                  type = types.attrsOf types.str;
                  default = {};
                  description = "Versioning parameters";
                };
              };
            });
            default = null;
            description = "Versioning configuration";
          };
        };
      });
      default = {};
      description = "Folders to synchronize";
    };
    
    openDefaultPorts = mkOption {
      type = types.bool;
      default = true;
      description = "Whether to open the default Syncthing ports in the firewall";
    };
    
    guiAddress = mkOption {
      type = types.str;
      default = "127.0.0.1:8384";
      description = "Address to serve the web GUI on";
    };
  };
  
  config = mkIf cfg.enable {
    services.syncthing = {
      enable = true;
      user = cfg.user;
      group = cfg.group;
      openDefaultPorts = cfg.openDefaultPorts;
      
      settings = {
        devices = deviceConfigs // {
          ${cfg.deviceName} = {
            id = thisDeviceId;
          };
        };
        
        folders = folderConfigs;
        
        options = {
          urAccepted = -1; # Disable usage reporting prompt
        };
        
        gui = {
          address = cfg.guiAddress;
        };
      };
    };
  };
}