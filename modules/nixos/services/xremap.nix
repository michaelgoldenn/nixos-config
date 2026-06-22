{ flake, lib, config, ... }:
{
  imports = [ flake.inputs.xremap-flake.nixosModules.default ];

  options.xremap.enable = lib.mkEnableOption "xremap";

  config = lib.mkIf config.xremap.enable {
  services.xremap = {
    # Ideally this would be user-level and have each user configure if they want it themself, but I couldn't figure that out
    enable = true;
    serviceMode = "system";
    watch = true;

    config.modmap = [
      {
        name = "Global";
        remap = {
          "CapsLock" = "Esc";
        };
      }
    ];
  };
  };
}
