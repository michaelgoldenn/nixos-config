{
  config,
  lib,
  pkgs,
  ...
}:
{
  ## Define options
  options.desktopEnvironment = {
    default = lib.mkOption {
      type = lib.types.enum [ "gnome" "cosmic" ];
      default = "gnome";
      description = "Desktop Environment";
    };
  };
  # import everything in sub-folder
  imports =
    with builtins;
    map (fn: ./${fn}) (filter (fn: fn != "default.nix") (attrNames (readDir ./.)));

  config = {
    ## Enable the right sub-directory
    gnome.enable = lib.mkIf (config.desktopEnvironment.default == "gnome") true;
  };
}
