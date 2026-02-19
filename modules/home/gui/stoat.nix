## vesktop
{
  config,
  lib,
  pkgs,
  ...
}:
{
  options.stoat.enable = lib.mkEnableOption "stoat";

  config = lib.mkIf config.stoat.enable {
    home.packages = [ pkgs.stoat-desktop ];
  };
}
