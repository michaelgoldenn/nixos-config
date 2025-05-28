{
  config,
  flake,
  lib,
  pkgs,
  ...
}: let
  app = "hyprland";
  cfg = config.mySystem.DE.${app};
in {
  options.mySystem.DE.${app} = {
    enable = lib.mkEnableOption "${app}";
  };
  config = lib.mkIf cfg.enable {
    programs.hyprland.enable = true; # enable Hyprland

    environment.systemPackages = [
      pkgs.kitty # required for the default Hyprland config
    ];
  };
}
