{
  config,
  lib,
  pkgs,
  ...
}:

with lib;

let
  cfg = config.syncthing;

  # Centralized device registry
  syncthingDevices = {
    umbriel = "D77PVFP-46PY65M-PUSFXRF-5DLFYSR-4GB4PCF-FRQWLHX-VERPPGI-O4KYAQ5";
    titania = "AY7KSET-AGDDFCU-25GZLT5-Y63PFI4-6RK2A5V-UFFWPMY-MOUIW5F-UJRYUAI";
    ophelia = "6R3DOKM-TZSDQZO-FIIBTQF-223PLHW-53KS22E-DZTFSQK-4FTYGT3-XSVBFAX";
    cordelia = "";
    # Add more devices here as needed
  };

  # Build device configuration from all devices defined across folders
  allDevices = unique (
    flatten (mapAttrsToList (folderName: folderCfg: folderCfg.devices) cfg.folders)
  );

  # Create device configs using the centralized registry
  deviceConfigs = listToAttrs (
    map (deviceName: {
      name = deviceName;
      value = {
        id =
          syncthingDevices.${deviceName}
            or (throw "Device ID for '${deviceName}' not defined in syncthingDevices registry");
      };
    }) allDevices
  );

  # Create folder configs
  folderConfigs = mapAttrs (folderName: folderCfg: {
    path = folderCfg.path;
    devices = folderCfg.devices;
    ignorePerms = folderCfg.ignorePerms;
    type = folderCfg.type;
    versioning = folderCfg.versioning;
  }) cfg.folders;

in
{
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
      type = types.attrsOf (
        types.submodule {
          options = {
            path = mkOption {
              type = types.str;
              description = "Path to the folder to sync";
            };

            devices = mkOption {
              type = types.listOf types.str;
              default = [ ];
              description = "List of device names to share this folder with";
            };

            ignorePerms = mkOption {
              type = types.bool;
              default = true;
              description = "Whether to ignore permission changes";
            };

            type = mkOption {
              type = types.enum [
                "sendreceive"
                "sendonly"
                "receiveonly"
              ];
              default = "sendreceive";
              description = "Folder type";
            };

            versioning = mkOption {
              type = types.nullOr (
                types.submodule {
                  options = {
                    type = mkOption {
                      type = types.enum [
                        "simple"
                        "trashcan"
                        "staggered"
                        "external"
                      ];
                      description = "Versioning type";
                    };
                    params = mkOption {
                      type = types.attrsOf types.str;
                      default = { };
                      description = "Versioning parameters";
                    };
                  };
                }
              );
              default = null;
              description = "Versioning configuration";
            };
          };
        }
      );
      default = { };
      description = "Folders to synchronize";
    };
  };

  config = mkIf cfg.enable {
    services.syncthing = {
      enable = true;
      openDefaultPorts = true;
      # should change these to not be hard-coded in the future
      user = "michael";
      group = "users";
      dataDir = "/home/youruser/.local/share/syncthing";
      configDir = "/home/michael/.config/syncthing";

      settings = {
        devices = deviceConfigs;
        folders = folderConfigs;
        options = {
          urAccepted = -1; # Disable usage reporting prompt
        };
      };
    };
  };
}
