{
  config,
  lib,
  pkgs,
  ...
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
    # which shells should be installed
    shells = lib.mkOption {
      description = "The list of shells that should be installed";
      type = lib.types.listOf lib.types.str;
      default = [ "nushell" ];
    };
    # the default shell
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
    # apparently can't set default in home-manager??? Need to look into this more
    nushell.enable = builtins.elem "nushell" config.shell.shells;
    zsh.enable = builtins.elem "zsh" config.shell.shells;
  };
}
