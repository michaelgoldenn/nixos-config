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

    xdg.portal = {
      enable = true;
      extraPortals = with pkgs; [
        xdg-desktop-portal-hyprland
        xdg-desktop-portal-gtk # needed for file pickers and some GTK apps
      ];
    };

    environment.systemPackages = with pkgs; [
      # Screenshot / screen capture
      grim # screenshot tool
      slurp # region selector (used with grim)
      satty # annotation tool
      swappy # snapshot editor
      mpvpaper # video/mpv wallpaper
      eww # widget system
      quickshell # alternative shell/widget layer
      playerctl # media player control (play/pause/next from keybinds)
      matugen # material you color generation
      wmctrl # window control scripting
    ];
  };
}
