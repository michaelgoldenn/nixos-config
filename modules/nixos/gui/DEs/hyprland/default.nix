## Hyprland compositor. The login screen, keyring, polkit agent and other pieces it shares
## with niri are in ../noctalia-session.nix.
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
      withUWSM = true;
      xwayland.enable = true;
    };

    xdg.portal.extraPortals = [ pkgs.xdg-desktop-portal-hyprland ];
  };
}
