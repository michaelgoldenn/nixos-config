## A Vim-Like editor
{
  config,
  lib,
  pkgs,
  ...
}:
{
  options.helix.enable = lib.mkEnableOption "helix";

  config = lib.mkIf config.helix.enable {
    home.packages = with pkgs; [
    ];
    programs = {
      helix = {
        enable = true;
        languages = builtins.fromTOML (builtins.readFile ./languages.toml) // { };
        settings = builtins.fromTOML (builtins.readFile ./config.toml) // { };
      };
    };
  };
}
