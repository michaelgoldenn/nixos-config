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

    deviceId = lib.mkOption {
      type = lib.types.str;
      description = "This device's Syncthing ID";
    };

    deviceName = lib.mkOption {
      type = lib.types.str;
      description = "This device's friendly name";
    };
  };

  config = {
    # everything's handled in the home-manager module
  };
}
