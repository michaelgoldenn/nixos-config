{
  config,
  lib,
  pkgs,
  ...
}:
{
  options.syncthing = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Enables Syncthing";
    };
  };
  config = lib.mkIf config.syncthing.enable {
    services.syncthing = {
      enable = true;
    };
  };
}
