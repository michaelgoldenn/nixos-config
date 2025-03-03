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

    environment.systemPackages = with pkgs; [
      lutris
      wget # needed for lutris to install epic games store
      r2modman
      vulkan-tools        # For vulkaninfo diagnostic tool
      vulkan-loader       # 64-bit Vulkan loader
      vulkan-validation-layers
      pkgsi686Linux.vulkan-loader  # 32-bit Vulkan loader
      archipelago
      # wine
      wineWowPackages.stable
      # EA Installer
      geckodriver
    ];

    environment.variables = {
      VK_ICD_FILENAMES = "/run/opengl-driver/share/vulkan/icd.d/nvidia_icd.json";
      DISABLE_LAYER_MESA_ENABLE_TIMELINE_SEMAPHORE_1 = "1";
    };
  };
}