{ config
, lib
, pkgs
, ...
}:
{
  options.gnome = {
    enable = lib.mkEnableOption "gnome";
  };
  config = lib.mkIf config.gnome.enable {
    services = {
      displayManager.gdm.enable = true;
      desktopManager.gnome.enable = true;
    };
    environment.systemPackages = with pkgs; [
      gnome-tweaks
    ];
  };
}
