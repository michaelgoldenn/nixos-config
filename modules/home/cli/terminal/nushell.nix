{
  pkgs,
  config,
  lib,
  ...
}:
let
  app = "nushell";
  cfg = config.opt.${app};
in
{
  options.opt.${app} = {
    enable = lib.mkEnableOption "${app}";
  };
  config = lib.mkIf cfg.enable {
    programs = {
      bash = {
        enable = true;
        initExtra = ''
          # Custom bash profile goes here
        '';
        enableCompletion = true;
      };
      nushell = {
        enable = true;
        # The config.nu can be anywhere you want if you like to edit your Nushell with Nu
        #configFile.source = ./config.nu;
        shellAliases = {
          g = "git";
          lg = "lazygit";
          code = "codium";
          #cd = "z";
        };
        extraConfig = ''
          let carapace_completer = {|spans|
            carapace $spans.0 nushell $spans | from json
          }

          $env.config = {
            show_banner: false,
           completions: {
             case_sensitive: false
             quick: true
             partial: true
             algorithm: "fuzzy"
             external: {
               enable: true
               max_results: 100
               completer: $carapace_completer
             }
           }
          }
          # Update PATH to include Nix profiles and custom paths
          $env.PATH = (
            $env.PATH
            | split row (char esep)
            | prepend /home/myuser/.apps
            | append /usr/bin/env
            | append ~/.nix-profile/bin    # Nix user profile
            | append /nix/var/nix/profiles/default/bin  # System Nix profile
          )
        '';
      };
      carapace = {
        enable = true;
        enableNushellIntegration = true;
      };

      zoxide = {
        enableNushellIntegration = true;
      };
    };
    home.sessionVariables = {
      NIX_BUILD_SHELL = "${pkgs.nushell}/bin/nu";
    };
  };
}