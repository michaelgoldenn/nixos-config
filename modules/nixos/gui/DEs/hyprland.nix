{
  config,
  lib,
  pkgs,
  ...
}:
{
  options.hyprland = {
    enable = lib.mkEnableOption "hyprland";
  };
  config = lib.mkIf config.hyprland.enable {
    programs.hyprland = {
      enable = true;
      withUWSM = true; # recommended for most users
      xwayland.enable = true; # Xwayland can be disabled.
    };
    xdg.portal = {
      enable = true;
      extraPortals = with pkgs; [ xdg-desktop-portal-hyprland ];
    };
    services = {
    };
    environment.systemPackages = with pkgs; [
    ];
  };
}
