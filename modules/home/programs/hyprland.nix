{
  config,
  lib,
  pkgs,
  ...
}:
let
  app = "hyprland";
  cfg = config.opt.${app};
in
{
  options.opt.${app} = {
    enable = lib.mkEnableOption "${app}";
  };

  config = lib.mkIf cfg.enable {
    wayland.windowManager.hyprland = {
      enable = true;
      settings = { };
      extraConfig = builtins.readFile ./hyprland.conf;
    };
    programs.wofi.enable = true;
    
    home.sessionVariables = {
      NIXOS_OZONE_WL = "1";
    };
  };
}