{ pkgs, config, lib, ... }:
{
  options = {
    mySystem.alvr.enable = lib.mkEnableOption "enables alvr";
  };
  config = lib.mkIf config.mySystem.alvr.enable {
    programs.alvr = {
      enable = true;
      openFirewall = true;
    };
  };
}