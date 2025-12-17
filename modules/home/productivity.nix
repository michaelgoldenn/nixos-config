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
      kimai
    ];
  };
}
