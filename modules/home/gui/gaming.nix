## All apps for playing video games (Apps for making games are somewhere else)
{
  config,
  lib,
  pkgs,
  flake,
  osConfig,
  ...
}:
let
  ftlman = flake.inputs.ftlman.packages.${pkgs.stdenv.hostPlatform.system}.default;
in
{
  options.gaming.enable = lib.mkEnableOption "gaming";

  config = lib.mkIf (osConfig != null && osConfig.gui.enable && config.gaming.enable) {
    home.packages = with pkgs; [
      # steam
      millennium-steam
      steam-run
      r2modman
      # ftlman
      lutris
      wine
      winetricks
      heroic
      protonup-qt
      prismlauncher # minecraft
      vintagestory
      ludusavi # game backups

      qbittorrent
      flake.inputs.risabh-packages.packages.${pkgs.stdenv.hostPlatform.system}.ab-download-manager
    ];

    # nexus mods "mod manager download" links -> patchwork
    # (desktop file lives in ~/.local/share/applications, not managed by nix)
    xdg.mimeApps.defaultApplications."x-scheme-handler/nxm" = "patchwork-gui-handler.desktop";
  };
}
