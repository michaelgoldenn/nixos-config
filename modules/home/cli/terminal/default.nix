{ config
, lib
, pkgs
, ...
}:
{
  ## Define options
  options.terminal = {
    default = lib.mkOption {
      type = lib.types.enum [ "ghostty" ];
      default = "ghostty";
      description = "Default terminal emulator";
    };
  };

  options.shell = {
    default = lib.mkOption {
      type = lib.types.enum [
        "nushell"
        "zsh"
      ];
      default = "nushell";
      description = "Default shell";
    };
  };

  # import everything in sub-folder
  imports =
    with builtins;
    map (fn: ./${fn}) (filter (fn: fn != "default.nix") (attrNames (readDir ./.)));

  ## Configuration based on options
  config = {
    ## Set Terminal
    home.packages = [ (pkgs.${config.terminal.default}) ];
    home.sessionVariables.TERMINAL = config.terminal.default;

    ## Set Shell
    programs.nushell.enable = config.shell.default == "nushell";
    programs.zsh.enable = config.shell.default == "zsh";
  };
}
