{ config
, lib
, pkgs
, ...
}:
{
  ## Define options
  options.desktopEnvironment = lib.mkOption {
      type = lib.types.enum [ "gnome" "cosmic" "hyprland" ];
      default = "gnome";
      description = "Desktop Environment";
  };
  # import everything in sub-folder
  imports =
    with builtins;
    map (fn: ./${fn}) (filter (fn: fn != "default.nix") (attrNames (readDir ./.)));

  config = {
    ## Enable the right sub-directory
    gnome.enable = config.desktopEnvironment == "gnome";
    cosmic.enable = config.desktopEnvironment == "cosmic";
    hyprland.enable = config.desktopEnvironment == "hyprland";
  };
}
