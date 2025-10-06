{
  config,
  lib,
  pkgs,
  osConfig,
  ...
}:
{
  options.syncthing = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Enables Syncthing in home-manager";
    };

    allDevices = lib.mkOption {
      type = lib.types.attrsOf (
        lib.types.submodule {
          options = {
            id = lib.mkOption { type = lib.types.str; };
            name = lib.mkOption { type = lib.types.str; };
          };
        }
      );
      default = { };
      description = "Registry of all Syncthing devices";
    };

    folders = lib.mkOption {
      type = lib.types.attrsOf (
        lib.types.submodule {
          options = {
            path = lib.mkOption {
              type = lib.types.str;
              description = "Path to the folder";
            };
            devices = lib.mkOption {
              type = lib.types.listOf lib.types.str;
              default = [ ];
              description = "List of device names to sync with. Empty list = all devices";
            };
          };
        }
      );
      default = { };
      description = "Folders to sync";
    };
  };

  config = lib.mkIf config.syncthing.enable {
    services.syncthing = {
      enable = true;

      settings.devices =
        lib.mapAttrs
          (name: device: {
            id = device.id;
          })
          (
            lib.filterAttrs (name: device: device.id != osConfig.syncthing.deviceId) config.syncthing.allDevices
          );

      settings.folders = lib.mapAttrs (name: folderConfig: {
        path = folderConfig.path;
        devices =
          if folderConfig.devices == [ ] then
            builtins.attrNames config.services.syncthing.settings.devices # All devices
          else
            folderConfig.devices; # Specific devices
      }) config.syncthing.folders;
    };
  };
}
