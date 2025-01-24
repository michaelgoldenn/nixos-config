{ lib, config, pkgs, ... }:
let
  app = "ghostty";
  cfg = config.opt.${app};
in
{
  options.opt.${app} = {
    enable = lib.mkEnableOption "${app}";
  };

  config = lib.mkIf cfg.enable {
    programs.ghostty = {
      enable = true;
    };
  };
}