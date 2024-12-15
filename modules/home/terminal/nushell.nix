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
       vi = "hx";
       vim = "hx";
       nano = "hx";
       };
   };  
    carapace.enable = true;
    carapace.enableNushellIntegration = true;
    zoxide = {
      enable = true;
      enableNushellIntegration = true; 
    };
  };
}