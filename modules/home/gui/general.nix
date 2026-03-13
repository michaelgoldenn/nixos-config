## general
{
  config,
  lib,
  pkgs,
  ...
}:
{
  options.general.enable = lib.mkEnableOption "general";

  config = lib.mkIf config.general.enable {
    home.packages = with pkgs; [
      mission-center
    ];
  };
}
