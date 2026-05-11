{
  config,
  lib,
  pkgs,
  ...
}:
{
  options.calibre.enable = lib.mkEnableOption "calibre";

  config = lib.mkIf config.calibre.enable {
    programs.calibre = {
      enable = true;
    };
  };
}
