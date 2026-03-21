{
  config,
  lib,
  pkgs,
  ...
}:
{
  ## Define options
  options.gui = {
    enable = lib.mkEnableOption "gui";
    desktopEnvironment = lib.mkOption {
      type = lib.types.enum [
        "gnome"
        "kde"
        "cosmic"
        "hyprland"
      ];
      default = "gnome";
      description = "Desktop Environment";
    };
  };

  # import everything in sub-folder
  imports =
    with builtins;
    map (fn: ./${fn}) (filter (fn: fn != "default.nix") (attrNames (readDir ./.)));

  config = lib.mkMerge [
    # Only create specialisations when GUI is enabled
    (lib.mkIf config.gui.enable {
      specialisation = {
        gnome.configuration = {
          gui.desktopEnvironment = "gnome";
        };
        # cosmic.configuration = {
        #   gui.desktopEnvironment = "cosmic";
        # };
        # hyprland.configuration = {
        #   gui.desktopEnvironment = "hyprland";
        # };
        kde.configuration = {
          gui.desktopEnvironment = "kde";
        };
      };
    })

    # Only enable desktop environments when GUI is enabled
    (lib.mkIf config.gui.enable {
      gnome.enable = config.gui.desktopEnvironment == "gnome";
      cosmic.enable = config.gui.desktopEnvironment == "cosmic";
      hyprland.enable = config.gui.desktopEnvironment == "hyprland";
      kde.enable = config.gui.desktopEnvironment == "kde";
    })
  ];
}
