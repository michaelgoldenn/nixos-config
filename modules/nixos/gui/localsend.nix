## An app to send to other compters on the local network
{
  config,
  lib,
  pkgs,
  ...
}:
{
  options.localsend.enable = lib.mkOption {
    type = lib.types.bool;
    default = true;
    description = "An app to send things to other compters on the local network";
  };

  config = lib.mkIf config.localsend.enable {
    programs.localsend = {
      enable = true;
      openFirewall = true;
    };
  };
}