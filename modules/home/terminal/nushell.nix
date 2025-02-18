{ pkgs, config, lib, ... }:
let 
  app = "nushell";
  cfg = config.opt.${app};
in 
{
  options.opt.${app} ={
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
        let carapace_completer = {|spans|
        carapace $spans.0 nushell $spans | from json
        }
        $env.config = {
          show_banner: false,
          completions: {
          case_sensitive: false # case-sensitive completions
          quick: true    # set to false to prevent auto-selecting completions
          partial: true    # set to false to prevent partial filling of the prompt
          algorithm: "fuzzy"    # prefix or fuzzy
          external: {
          # set to false to prevent nushell looking into $env.PATH to find more suggestions
              enable: true 
          # set to lower can improve completion performance at the cost of omitting some options
              max_results: 100 
              completer: $carapace_completer # check 'carapace_completer' 
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