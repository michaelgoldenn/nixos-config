{
  flake,
  pkgs,
  lib,
  ...
}: let
  inherit (flake) config inputs;
  inherit (inputs) self;
  #app = "obsidian";
  #cfg = config.opt.${app};
in {
  #options.opt.${app} = {
  #  enable = lib.mkEnableOption "${app}";
  #};
  #config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [
      obsidian
    ];
  #};
  /*
     programs.obsidian = {
    enable = true;
    vaults.test-vault = {
      enable = true;
      path = "~/Documents/home-manager-test";
    };
  };
  */
}
