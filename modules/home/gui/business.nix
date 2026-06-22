# I don't have any business, but if I did this is what I'd use
{
  config,
  lib,
  pkgs,
  ...
}:
{
  options.business.enable = lib.mkEnableOption "business";

  config = lib.mkIf config.business.enable {
    home.packages = with pkgs; [
      libreoffice
    ];
  };
}
