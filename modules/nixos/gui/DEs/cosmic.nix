{ config
, lib
, pkgs
, ...
}:
{
  options.cosmic = {
    enable = lib.mkEnableOption "cosmic";
  };
  config = lib.mkIf config.cosmic.enable {
    services = {
      displayManager.cosmic-greeter.enable = true;
      desktopManager.cosmic.enable = true;
    };
    environment.systemPackages = with pkgs; [
    ];
  };
}
