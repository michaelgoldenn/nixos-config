{ lib, config, pkgs, ... }:
let
  app = "ghostty";
  cfg = config.opt.${app};
in
{
  options.opt.${app} = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Whether to enable ${app}";
    };
  };

  config = lib.mkIf cfg.enable {
    programs.ghostty = {
      enable = true;
    };
  };
}