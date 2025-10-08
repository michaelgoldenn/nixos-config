## Enables software used to make games
{
  config,
  lib,
  pkgs,
  ...
}:
{
  options.making_games.enable = lib.mkEnableOption "making_games";

  config = lib.mkIf config.making_games.enable {
    home.packages = with pkgs; [
      obsidian
      blender
      aseprite
      godot
    ];
  };
}
