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

/*     # Define the sops-nix secret
    sops.secrets."ai/anthropic" = {
      # Adjust owner to match the user that runs open-webui
      owner = config.services.open-webui.user or "open-webui";
    }; */

    services.open-webui = {
      enable = true;
      package = nixpkgs-stable.legacyPackages.${pkgs.system}.open-webui;
      environment = {
        ANONYMIZED_TELEMETRY = "False";
        DO_NOT_TRACK = "True";
        SCARF_NO_ANALYTICS = "True";
        OLLAMA_API_BASE_URL = "http://127.0.0.1:11434/api";
        OLLAMA_BASE_URL = "http://127.0.0.1:11434";
        # Remove ANTHROPIC_API_KEY from here
      };
    };
    
    # Add the secret to the service's environment through systemd
    systemd.services.open-webui = {
      serviceConfig = {
        # Load the secret into the environment
        EnvironmentFile = [ 
          "${config.sops.secrets."ai/anthropic".path}"
        ];
      };
      # Ensure the secret is available before starting the service
      requires = [ "sops-nix.service" ];
      after = [ "sops-nix.service" ];
    };
  };
}