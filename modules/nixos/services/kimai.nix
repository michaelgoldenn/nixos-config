# a time tracking app
{
  flake,
  lib,
  config,
  pkgs,
  ...
}:
{
  options.kimai.enable = lib.mkEnableOption "kimai";

  config = lib.mkIf config.kimai.enable {
    environment.systemPackages = [ pkgs.kimai ];
    services.kimai = {

    };
  };
}
