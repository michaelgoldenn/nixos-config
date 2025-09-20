{ config, pkgs, lib, flake, ... }:
{
  imports = [ flake.inputs.xremap-flake.homeManagerModules.default ];
  services.xremap = {
    serviceMode = "system";
    watch = true;
    config.modmap = [{
      name = "Global";
      remap = { "CapsLock" = "Esc"; };
    }];
  };
}
