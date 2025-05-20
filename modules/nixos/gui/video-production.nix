{
  config,
  flake,
  lib,
  pkgs,
  ...
}: let
  app = "video-production";
  cfg = config.mySystem.${app};
in {
  # setting up the options
  options.mySystem.${app} = {
    enable = lib.mkEnableOption "${app}";
  };
  # setting up configuration
  config = lib.mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      davinci-resolve
      manim
    ];
  };
}
