{ pkgs, ... }:
{
  programs = {
    bash = {
      enable = true;
      initExtra = ''
        # Custom bash profile goes here
      '';
    };
    nushell = { 
      enable = true;
      # The config.nu can be anywhere you want if you like to edit your Nushell with Nu
      #configFile.source = ./.../config.nu;
      shellAliases = {
        g = "git";
        lg = "lazygit";
        cd = "z";
      };
      # See the Nushell docs for more options.
/*       conf = builtins.toJSON {
          "$env.config" = {
            show_banner = false;
              name = "abbr";
              modifier = "control";
              keycode = "space";
              mode = ["emacs"  "vi_normal" "vi_insert"];
              event = [
              { send = "menu"; name = "abbr_menu";}
              { edit = "insertchar"; value = " ";}
              ];

              # TODO: get the Menus section from the extraConfig into this toJSON struct
          };
      }; */
      extraConfig = ''
        $env.config = {
          show_banner: false
        }
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
}