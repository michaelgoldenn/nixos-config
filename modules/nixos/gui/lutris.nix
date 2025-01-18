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
    hardware.graphics.enable32Bit = true;

    environment.systemPackages = with pkgs; [
      lutris
      wget
      cabextract
      unzip
      p7zip
      winetricks
      wineWowPackages.stable
      wineWowPackages.waylandFull
      wine64
      dxvk
      vulkan-tools
      vulkan-headers
      vulkan-loader
      vulkan-validation-layers
    ];
  };
}