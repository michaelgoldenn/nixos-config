{ pkgs, config, lib, ... }:
let 
  app = "making-games";
  cfg = config.opt.${app};
in 
{
  options.opt.${app} ={
    enable = lib.mkEnableOption "${app}";
  };
  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [
      godot_4
      blender
      aseprite
    ];
  };
}