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

  config = {
    wayland.windowManager.hyprland = lib.mkIf cfg.enable {
      enable = true;
      settings = { };
      extraConfig = builtins.readFile ./hyprland.conf;
    };
  };
}
