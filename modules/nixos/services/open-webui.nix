{
  flake,
  lib,
  config,
  pkgs,
  ...
}: let
  app = "open-webui";
  cfg = config.mySystem.services.${app};
  inherit (flake) inputs;
  inherit (inputs) nixpkgs-stable;
in {
  options.mySystem.services.${app} = {
    enable = lib.mkEnableOption "${app}";
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = [pkgs.open-webui];
    services.open-webui = {
      enable = true;
      package = nixpkgs-stable.legacyPackages.${pkgs.system}.open-webui;
    };
  };
}
