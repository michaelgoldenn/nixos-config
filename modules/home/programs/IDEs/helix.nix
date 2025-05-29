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
  };
}
