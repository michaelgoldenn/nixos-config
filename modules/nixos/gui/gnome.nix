{
  config,
  flake,
  lib,
  pkgs,
  ...
}: let
  app = "gnome";
  cfg = config.mySystem.DE.${app};
in {
  options.mySystem.DE.${app} = {
    enable = lib.mkEnableOption "${app}";
  };
  config = lib.mkIf cfg.enable {
    services.xserver = {
      displayManager.gdm.enable = true;
      desktopManager.gnome.enable = true;
    };

    environment.gnome.excludePackages = with pkgs; [
      gnome-console
      gnome-keyring
    ];

    environment.systemPackages = with pkgs; [
      gnome-tweaks
      gnomeExtensions.gsconnect
      gnomeExtensions.fuzzy-app-search
      gnomeExtensions.color-picker
    ];
  };
}
