{
  flake,
  lib,
  config,
  inheritedConfig,
  pkgs,
  ...
}:
{
  programs.neovim = {
    enable = true;
    viAlias = true;
    vimAlias = true;
  };
}