{
  config,
  lib,
  pkgs,
  ...
}:
{
  options.kde = {
    enable = lib.mkEnableOption "kde";
  };
  config = lib.mkIf config.kde.enable {
    services = {
      desktopManager.plasma6.enable = true;
      displayManager.sddm.enable = true;
      displayManager.sddm.wayland.enable = true;
    };
    environment.systemPackages = with pkgs; [
    ];
  };
}
