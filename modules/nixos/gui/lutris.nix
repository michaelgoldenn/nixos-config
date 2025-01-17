{ config, pkgs, lib, ... }:
let 
  app = "lutris";
  cfg = config.mySystem.${app};
in 
{
  options.mySystem.${app} =
    {
      enable = lib.mkEnableOption "${app}";
    };

  config = lib.mkIf cfg.enable {

    programs.nix-ld.enable = true;
    hardware.graphics.enable32Bit = true ;
    #hardware.pulseaudio.support32Bit = true;
    environment.systemPackages = with pkgs; [
      lutris
      heroic-unwrapped

      wineWowPackages.stable

    ];
    environment.sessionVariables = {
      WINEARCH = "win64";
    };
  };
}