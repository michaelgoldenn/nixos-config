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
        aw-watcher-afk = {
          package = pkgs.activitywatch;
          settings = {
            timeout = 300;
            poll_time = 2;
          };
        };

        aw-watcher-window = {
          package = pkgs.activitywatch;
          settings = {
            poll_time = 1;
            exclude_title = true;
          };
        };
      };
    };
  };
}
