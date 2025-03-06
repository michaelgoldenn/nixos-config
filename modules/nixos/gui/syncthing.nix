{
  config,
  pkgs,
  lib,
  ...
}: let
  app = "syncthing";
  cfg = config.mySystem.services.${app};
in
  # goto http://127.0.0.1:8384/# for syncthing
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
        versioning = {
          type = "staggered";
          fsPath = "/syncthing/backup";
          params = {
            cleanInterval = "3600";
            maxAge = "31536000";
          };
        };
      };
      one_game_a_week = {
        enable = lib.mkEnableOption "one-game-a-week";
        path = lib.mkOption {
          type = lib.types.str;
          default = "/home/michael/projects/one-game-a-week";
          description = "Path to file";
        };
        devices = lib.mkOption {
          type = lib.types.listOf lib.types.str;
          default = [];
          description = "List of device names to share the directory with";
        };
        versioning = {
          type = "staggered";
          fsPath = "/syncthing/backup";
          params = {
            cleanInterval = "3600";
            maxAge = "31536000";
          };
        };
      };
      making-games = {
        enable = lib.mkEnableOption "making-games";
        path = lib.mkOption {
          type = lib.types.str;
          default = "/home/michael/projects/making-games";
          description = "Path to file";
        };
        devices = lib.mkOption {
          type = lib.types.listOf lib.types.str;
          default = [];
          description = "List of device names to share the directory with";
        };
        versioning = {
          type = "staggered";
          fsPath = "/syncthing/backup";
          params = {
            cleanInterval = "3600";
            maxAge = "31536000";
          };
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
              "obsidian-vault" = {
                path = cfg.obsidian_vault.path;
                devices = cfg.obsidian_vault.devices;
              };
            })
            (lib.mkIf cfg.one_game_a_week.enable {
              "One game a week" = {
                path = cfg.one_game_a_week.path;
                devices = cfg.one_game_a_week.devices;
              };
            })
            (lib.mkIf cfg.one_game_a_week.enable {
              "making-games" = {
                path = cfg.making-games.path;
                devices = cfg.making-games.devices;
              };
            })
          ];
        };
      };
    };
  }
