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
}