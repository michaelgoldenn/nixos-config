## A teminal-based file explorer
{ config, lib, pkgs, ... }:
{
  options.yazi.enable = lib.mkOption {
    type = lib.types.bool;
    default = true;
    description = "A teminal-based file explorer";
  };
  config = lib.mkIf config.yazi.enable {
  programs.yazi = {
    enable = true;
  };
};
}
