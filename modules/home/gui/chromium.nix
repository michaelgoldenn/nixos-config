{
  config,
  lib,
  pkgs,
  ...
}:
{
  options.chromium.enable = lib.mkEnableOption "chromium";

  config = lib.mkIf config.chromium.enable {
    home.packages = [ pkgs.chromium ];
  };
}
