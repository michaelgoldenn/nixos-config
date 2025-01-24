{ lib, config, ... }:
let 
  app = "zsh";
  cfg = config.opt.${app};
in 
{
  options.opt.${app} ={
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

      zsh = {
        enable = false;
        autosuggestion.enable = true;
        syntaxHighlighting.enable = true;
        envExtra = ''
          # Custom zshrc goes here
          export PATH=/etc/nixos/bash:$PATH
        '';
      };

      # Type `z <pat>` to cd to some directory
      zoxide.enable = true;

      # Better shell prompt!
  /*     starship = {
        enable = true;
        settings = {
          username = {
            style_user = "blue bold";
            style_root = "red bold";
            format = "[$user]($style) ";
            disabled = false;
            show_always = true;
          };
          hostname = {
            ssh_only = false;
            ssh_symbol = "🌐 ";
            format = "on [$hostname](bold red) ";
            trim_at = ".local";
            disabled = false;
          };
        };
      }; */
    };
  };
}
