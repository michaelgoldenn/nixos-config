{
  config,
  lib,
  pkgs,
  ...
}:
let
  app = "hyprland";
  cfg = config.myHome.programs.${app};
in
{
  options.myHome.programs.${app} = {
    enable = lib.mkEnableOption "${app}";
  };

  config = lib.mkIf cfg.enable {
    wayland.windowManager.hyprland = {
      enable = true;
      settings = { };
      extraConfig = builtins.readFile ./hyprland.conf;
    };
  };
}
