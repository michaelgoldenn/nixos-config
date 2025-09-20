## A Vim-Like editor written in Rust
{ config
, lib
, pkgs
, ...
}:
{
  options.helix.enable = lib.mkOption {
    type = lib.types.bool;
    default = true;
    description = "A Vim-Like editor written in Rust";
  };

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
