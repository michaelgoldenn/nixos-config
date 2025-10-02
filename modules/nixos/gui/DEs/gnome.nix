{
  config,
  lib,
  pkgs,
  ...
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
    # excludes gnome-console if nobody has selected gnome-console as their default shell
    environment.gnome.excludePackages =
      with pkgs;
      lib.optionals (
        !lib.any (user: user.shell.default or "" == "gnome-console") (
          lib.attrValues config.home-manager.users
        )
      ) [ gnome-console ];
  };
}
