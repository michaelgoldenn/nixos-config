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
      extraConfig = let
        conf = builtins.toJSON {
          show_banner = false;
          keybindings = [
            {
              # add abbreviation support with ctrl + space
              name = "abbr";
              modifier = "control";
              keycode = "space";
              mode = ["emacs" "vi_normal" "vi_insert"];
              event = [
                { send = "menu"; name = "abbr_menu"; }
                { edit = "insertchar"; value = " "; }
              ];
            }
          ];
        };
        in ''
        $env.config = ${conf};
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