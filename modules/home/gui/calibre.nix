{
  config,
  lib,
  pkgs,
  ...
}:
{
  options.calibre.enable = lib.mkEnableOption "calibre";

  config = lib.mkIf config.calibre.enable {
    home.packages = with pkgs; [
      calibre
    ];
  };
}
