## vesktop
{ config, lib, ... }:
{
  options.vesktop.enable = lib.mkEnableOption "vesktop";

  config = lib.mkIf config.vesktop.enable {
    programs.vesktop = {
      enable = true;
    };
  };
}
