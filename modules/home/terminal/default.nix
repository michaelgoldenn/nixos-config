{config, lib, pkgs, ...}:
{
  ## Terminal
  options.opt."terminal" = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Enables the terminal";
    };
    
    default = lib.mkOption {
      type = lib.types.str;
      default = "ghostty";
      description = "Default terminal emulator";
    };
  };
  ## Shell
  options.opt."shell" = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Enables the shell";
    };
    
    default = lib.mkOption {
      type = lib.types.enum [ "nushell" "zsh" ];
      default = "nushell";
      description = "Default shell to use";
    };
  };

  imports = 
    with builtins;
    map
      (fn: ./${fn})
      (filter (fn: fn != "default.nix") (attrNames (readDir ./.)));
  ## Terminal
  config = lib.mkIf config.opt.terminal.enable {
    home.packages = [ (pkgs.${config.opt.terminal.default}) ];
    environment.sessionVariables.TERMINAL = config.opt.terminal.default;
  } //
  ## Shell
  lib.mkIf config.opt.shell.enable {
    opt = {
      nushell.enable = config.opt.shell.default == "nushell";
      zsh.enable = config.opt.shell.default == "zsh";
    };
  };
}