{
  pkgs,
  config,
  lib,
  ...
}: let
  app = "nushell";
  cfg = config.opt.${app};
in {
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
          #cd = "z";
        };
        extraConfig = ''
          def carapace_completer [spans: list] {
            let cmd = if ($spans | length) > 0 { $spans.0 } else { "" }
            let expanded_alias = (scope aliases | where name == $cmd | get -i 0.expansion) | default $cmd
            carapace $expanded_alias nushell $spans | from json
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
                completer: carapace_completer  # No $ prefix when referencing the function
              }
            }
          }

          $env.PATH = ($env.PATH |
            split row (char esep) |
            prepend /home/myuser/.apps |
            append /usr/bin/env
          )
        '';
      };
      carapace = {
        enable = true;
        enableNushellIntegration = true;
      };
      zoxide = {
        enable = true;
        enableNushellIntegration = true;
      };
    };
    home.sessionVariables = {
      NIX_BUILD_SHELL = "${pkgs.nushell}/bin/nu";
    };
  };
}
