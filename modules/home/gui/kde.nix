## KDE Plasma user-level configuration.
## Plasma itself is set up on the NixOS side in /modules/nixos/gui/DEs/kde.nix.
## This module only applies when the booted specialisation has KDE enabled.
## Appearance is configured with plasma-manager: https://github.com/nix-community/plasma-manager
## Option reference: https://nix-community.github.io/plasma-manager/options.xhtml
## Tip: run `nix run github:nix-community/plasma-manager` to dump your current
## Plasma settings as plasma-manager config, handy for copying things set in the GUI.
{
  flake,
  config,
  lib,
  pkgs,
  osConfig,
  ...
}:
{
  imports = [ flake.inputs.plasma-manager.homeModules.plasma-manager ];

  options.kde.enable = lib.mkOption {
    type = lib.types.bool;
    default = osConfig != null && (osConfig.kde.enable or false);
    defaultText = lib.literalExpression "osConfig.kde.enable";
    description = "Whether to apply the KDE Plasma user configuration";
  };

  config = lib.mkIf config.kde.enable {
    home.packages = with pkgs; [
    ];

    programs.plasma = {
      enable = true;
      # when true, any setting not declared here gets reset to default on each switch
      overrideConfig = false;

      workspace = {
        # Colors, wallpaper and cursor come from stylix (modules/home/background/stylix.nix).
        # Setting these here would fight with it; disable stylix.targets.kde first if you want to.
        # lookAndFeel = "org.kde.breezedark.desktop";
        # cursor = { theme = "Bibata-Modern-Classic"; size = 20; };
        iconTheme = "breeze-dark";
        theme = "breeze-dark"; # Plasma style (panels, widgets)
        clickItemTo = "select"; # "select" = double-click to open, "open" = single-click
        enableMiddleClickPaste = true;
        # windowDecorations = {
        #   library = "org.kde.breeze";
        #   theme = "Breeze";
        # };
      };

      panels = [
        {
          location = "bottom";
          height = 44;
          floating = true;
          # hiding = "none"; # "autohide", "dodgewindows", "windowsgobelow", ...
          widgets = [
            "org.kde.plasma.kickoff"
            {
              iconTasks.launchers = [
                "applications:org.kde.dolphin.desktop"
                "applications:firefox.desktop"
              ];
            }
            "org.kde.plasma.marginsseparator"
            "org.kde.plasma.systemtray"
            "org.kde.plasma.digitalclock"
          ];
        }
      ];

      kwin = {
        effects = {
          blur.enable = true;
          wobblyWindows.enable = false;
        };
        # nightLight = {
        #   enable = true;
        #   mode = "times";
        #   temperature.night = 4000;
        # };
        # virtualDesktops = {
        #   number = 4;
        #   rows = 1;
        # };
      };

      fonts = {
        # general = { family = "DejaVu Sans"; pointSize = 10; };
        # fixedWidth = { family = "JetBrainsMono Nerd Font"; pointSize = 10; };
      };

      # shortcuts = {
      #   kwin."Window Close" = "Meta+Q";
      # };

      # raw escape hatch for anything without a dedicated option (writes to ~/.config/<file>)
      # configFile = {
      #   kdeglobals.KDE.AnimationDurationFactor = 0.5;
      # };
    };
  };
}
