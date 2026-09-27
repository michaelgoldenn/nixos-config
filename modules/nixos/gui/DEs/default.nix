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
    # Only create specialisations when GUI is enabled.
    # The base config uses gui.desktopEnvironment; specialisations are only made for the others.
    # Each one writes its name to /etc/specialisation, which `nh os switch` reads to
    # re-activate the same specialisation instead of falling back to the base config.
    (lib.mkIf config.gui.enable {
      specialisation =
        lib.genAttrs
          (lib.remove config.gui.desktopEnvironment [
            "gnome"
            # "cosmic"
            "hyprland"
            "kde"
          ])
          (name: {
            configuration = {
              gui.desktopEnvironment = lib.mkForce name;
              environment.etc."specialisation".text = name;
            };
          });
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
