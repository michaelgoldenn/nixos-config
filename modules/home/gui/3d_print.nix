## Enables 3d printing-related software
{
  config,
  lib,
  pkgs,
  ...
}:
{
  options.printing_3d.enable = lib.mkEnableOption "printing_3d";

  config = lib.mkIf config.printing_3d.enable {
    home.packages = with pkgs; [
      prusa-slicer
    ];
  };
}
