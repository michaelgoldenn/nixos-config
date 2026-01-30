## productivity-related apps
{
  config,
  pkgs,
  lib,
  ...
}:
{
  options.productivity.enable = lib.mkEnableOption "productivity";

  config = lib.mkIf config.productivity.enable {
    home.packages = with pkgs; [
      anki
    ];
    # Activitywatch, the time tracker
    services.activitywatch = {
      enable = true;
      watchers = {
        aw-watcher-window-wayland = {
          package = pkgs.aw-watcher-window-wayland;
        };
      };
    };
  };
}
