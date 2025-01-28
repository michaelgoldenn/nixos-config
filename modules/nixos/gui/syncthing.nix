{ config, pkgs, lib, ... }:
let 
  app = "syncthing";
  cfg = config.mySystem.services.${app};
in
{
  options.mySystem.services.${app} = {
    enable = lib.mkEnableOption "enables ${app}";
    known_devices = lib.mkOption {
      type = lib.types.attrsOf (lib.types.submodule {
        options = {
          id = lib.mkOption {
            type = lib.types.str;
            description = "Device ID";
          };
          name = lib.mkOption {
            type = lib.types.str;
            description = "Device name";
          };
        };
      });
      default = {};
      description = "Known devices to sync with";
    };
    obsidian_vault = {
      enable = lib.mkEnableOption "enables syncing of Obsidian vault";
      path = lib.mkOption {
        type = lib.types.str;
        default = "/home/michael/Documents/obsidian-vault";
        description = "Path to Obsidian vault";
      };
      devices = lib.mkOption {
        type = lib.types.listOf lib.types.str;
        default = [];
        description = "List of device names to share the Obsidian vault with";
      };
    };
  };

  config = lib.mkIf cfg.enable {
    services.syncthing = {
      enable = true;
      group = "users";
      user = "michael";
      dataDir = "/home/michael/Documents";
      configDir = "/home/michael/Documents/.config/syncthing";
      overrideDevices = true;
      overrideFolders = true;
      settings = {
        devices = cfg.known_devices;
        folders = lib.mkMerge [
          (lib.mkIf cfg.obsidian_vault.enable {
            "ObsidianVault" = {
              path = cfg.obsidian_vault.path;
              devices = cfg.obsidian_vault.devices;
            };
          })
          # Add more folders here as needed
        ];
      };
    };
  };
}