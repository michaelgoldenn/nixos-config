{
  flake,
  lib,
  config,
  inheritedConfig,
  pkgs,
  ...
}: let
  inherit (flake) config inputs;
  inherit (inputs) self;
in {
  programs.helix = {
    enable = true;
    languages = builtins.fromTOML (builtins.readFile ./helix-config/languages.toml);
  };
}
