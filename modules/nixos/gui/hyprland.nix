{
  config,
  flake,
  lib,
  pkgs,
  ...
}:
let
  inherit (flake) inputs;
  app = "hyprland";
  cfg = config.mySystem.DE.${app};
in
{
  options.mySystem.DE.${app} = {
    enable = lib.mkEnableOption "${app}";
  };
  config = lib.mkIf cfg.enable {
    #   programs.hyprland = {
    #     enable = true;
    #     package = inputs.hyprland.packages.${pkgs.system}.hyprland;
    #     # settings = { };
    #     # extraConfig = builtins.readFile ./hyprland.conf;
    #   };

    #   wayland.windowManager.hyprland.enable = true;

    #   environment.systemPackages = [
    #     pkgs.kitty
    #   ];
  };
}
