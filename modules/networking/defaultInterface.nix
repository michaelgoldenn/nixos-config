{ config, lib, ... }:
{
  options = {
    mySystem.networking = {
      primaryInterface = lib.mkOption {
        type = lib.types.str;
        description = "Primary network interface name";
        example = "enp3s0";
      };
    };
  };
}