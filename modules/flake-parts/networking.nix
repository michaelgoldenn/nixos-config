{ config, lib, ... }: {
  options = {
    networkConfig = lib.mkOption {
      type = lib.types.attrsOf lib.types.anything;
      default = {};
      description = "Network configuration options";
    };
  };
}