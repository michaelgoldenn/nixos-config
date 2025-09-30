{ lib, config, ... }:
let
  app = "zsh";
  cfg = config.${app};
in
{
  options.${app} = {
    enable = lib.mkEnableOption "${app}";
  };
  config = lib.mkIf cfg.enable {

    programs = {
      # on macOS, you probably don't need this
      bash = {
        enable = true;
        initExtra = ''
          # Custom bash profile goes here
        '';
      };

      # For macOS's default shell.
      zsh = {
        enable = lib.mkDefault true;
        autosuggestion.enable = true;
        syntaxHighlighting.enable = true;
        enableCompletion = true;
        envExtra = ''
          # Custom ~/.zshenv goes here
        '';
        profileExtra = ''
          # Custom ~/.zprofile goes here
        '';
        loginExtra = ''
          # Custom ~/.zlogin goes here
        '';
        logoutExtra = ''
          # Custom ~/.zlogout goes here
        '';
      };
    };
  };
}
