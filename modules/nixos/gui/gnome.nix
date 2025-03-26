{ pkgs, ... }:
{
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
  ];
}
