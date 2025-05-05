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
    programs.adb.enable = true;
    users.users.michael.extraGroups = ["adbusers"];
    services.udev.packages = [ pkgs.android-udev-rules ];
  };
}