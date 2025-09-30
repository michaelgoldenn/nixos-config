{ flake, ... }:
{
  imports = [ flake.inputs.xremap-flake.nixosModules.default ];

  services.xremap = {
    # Ideally this would be user-level and have each user configure if they want it themself, but I couldn't figure that out
    serviceMode = "system";
    watch = true;

    config.modmap = [{
      name = "Global";
      remap = { "CapsLock" = "Esc"; };
    }];
  };
}
