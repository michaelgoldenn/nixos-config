## All apps for playing video games (Apps for making games are somewhere else) 
{ config, lib, pkgs, ... }:
{
  options.gaming.enable = lib.mkEnableOption "gaming";

  config = lib.mkIf config.gaming.enable {
    home.packages = with pkgs; [
      steam
      lutris
      prismlauncher # minecraft
    ];
  };
}
