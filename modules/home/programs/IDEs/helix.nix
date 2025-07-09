{
  #flake,
  ...
}:
let
  #inherit (flake) config inputs;
in
{
  programs.helix = {
    enable = true;
    languages = builtins.fromTOML (builtins.readFile ./helix-config/languages.toml) // {
    };
    settings = builtins.fromTOML (builtins.readFile ./helix-config/config.toml) // {
    };
  };
}
