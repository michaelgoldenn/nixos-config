{ config, pkgs, lib, ... }:

with lib;

let
  cfg = config.mySystem.vr;
in {
  imports = [
    ./alvr.nix
    ./wivrn.nix
  ];

  options.mySystem.vr = {
    enable = mkEnableOption "VR support";
  };

  config = mkIf cfg.enable {
    mySystem.alvr.enable = true;
    mySystem.wivrn.enable = true;
  };
}