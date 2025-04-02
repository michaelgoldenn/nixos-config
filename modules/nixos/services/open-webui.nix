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

  # Create a wrapped package that reads the secret at runtime
  wrappedOpenWebUI = pkgs.writeShellScriptBin "open-webui" ''
    export ANTHROPIC_API_KEY=$(cat /run/secrets/ai/anthropic)
    exec "${nixpkgs-stable.legacyPackages.${pkgs.system}.open-webui}/bin/open-webui" "$@"
  '';
in {
  options.mySystem.services.${app} = {
    enable = lib.mkEnableOption "${app}";
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = [wrappedOpenWebUI];

    services.open-webui = {
      enable = true;
      package = wrappedOpenWebUI;
      environment = {
        ANONYMIZED_TELEMETRY = "False";
        DO_NOT_TRACK = "True";
        SCARF_NO_ANALYTICS = "True";
        WEBUI_AUTH = "False";
        OLLAMA_API_BASE_URL = "http://127.0.0.1:11434/api";
        OLLAMA_BASE_URL = "http://127.0.0.1:11434";
        # Remove ANTHROPIC_API_KEY from here
      };
    };
  };
}
