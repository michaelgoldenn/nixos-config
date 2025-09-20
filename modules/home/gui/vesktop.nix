## A Discord client with many extensions
{ config, lib, ... }:
{
  options.vesktop.enable = lib.mkOption {
    type = lib.types.bool;
    default = true;
    description = "A Discord client with many extensions";
  };

  config = lib.mkIf config.vesktop.enable {
  programs.vesktop = {
    enable = true;
  };
};
}
