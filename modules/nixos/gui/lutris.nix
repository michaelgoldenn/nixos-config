{ config, pkgs, lib, ... }:
let 
  app = "lutris";
  cfg = config.mySystem.${app};
in 
{
  options.mySystem.${app} = {
    enable = lib.mkEnableOption "${app}";
  };

  config = lib.mkIf cfg.enable {
    #programs.nix-ld.enable = true;
    hardware.graphics.extraPackages = with pkgs; [
      rocmPackages.clr
    ];

    environment.systemPackages = with pkgs; [
      lutris
      vulkan-tools
    ];
  };
}