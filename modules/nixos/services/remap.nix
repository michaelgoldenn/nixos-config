{ config, pkgs, lib, flake, ... }:
with lib;
with types;
let 
  inherit (flake) inputs;
  cfg = config.services.remap;
in
{
  imports = [ inputs.xremap-flake.nixosModules.default ];

  options.services.remap = {
    enable = mkEnableOption "remap service";
    capsToEsc = mkOption {
      type = types.bool;
      default = false;
    };
  };

  config = mkIf cfg.enable {
    services.xremap = {
      serviceMode = "system";
      watch = true;
      config = {
        modmap = [ ] ++ optionals cfg.capsToEsc [{
          name = "CapsLock -> Escape";
          remap = { CapsLock = "Escape"; };
        }];
        keymap = [ ];
      };
    };
  };
}