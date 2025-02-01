{ lib, config, pkgs, ...}:
let
  app = "open-webui";
  cfg = config.mySystem.services.${app};
in
{
  options.mySystem.services.${app} =
    {
      enable = lib.mkEnableOption "${app}";
    };
  
  config = lib.mkIf cfg.enable {
    environment.systemPackages = [pkgs.open-webui];
    services.open-webui = {
      enable = true;
    };
  };
}