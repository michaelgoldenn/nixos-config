## All apps for playing video games (Apps for making games are somewhere else)
{
  config,
  lib,
  pkgs,
  flake,
  ...
}:
let
  ftlman = flake.inputs.ftlman.packages.${pkgs.system}.default;
in
{
  options.gaming.enable = lib.mkEnableOption "gaming";

  config = lib.mkIf config.gaming.enable {
    home.packages = with pkgs; [
      steam
      steam-run
      r2modman
      ftlman
      lutris
      prismlauncher # minecraft
      ludusavi # game backups
    ];
  };
}
