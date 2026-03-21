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
        awatcher = {
          package = pkgs.awatcher;
          settings = {
            poll-time-window-seconds = 6;
            poll-time-idle-seconds = 10;
            idle-timeout-seconds = 180;
          };
        };
      };
    };
  };
}
