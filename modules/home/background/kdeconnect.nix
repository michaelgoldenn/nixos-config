{
  config,
  lib,
  pkgs,
  ...
}:
{
  options.kdeconnect.enable = lib.mkEnableOption "kdeconnect";
  config = lib.mkIf config.kdeconnect.enable {
    programs.gnome-shell = {
      enable = true;
      extensions = [{ package = pkgs.gnomeExtensions.gsconnect; }];
    };
  };
}
