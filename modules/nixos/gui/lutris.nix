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
      ## Packages I may or may not need. I was just throwing the kitchen sink at the Epic Installer and seeing what worked
      wget
      cabextract 
      unzip
      p7zip
      winetricks
      wineWowPackages.staging
      wineWowPackages.waylandFull
      wine
      bluez
      vkd3d-proton
      dxvk
      vkd3d
      vulkan-tools
      vulkan-headers
      vulkan-loader
      vulkan-validation-layers
      vkd3d-proton
      # EA Installer
      geckodriver


      # Not lutris
      goldberg-emu
    ];
  };
}