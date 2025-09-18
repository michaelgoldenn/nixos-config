{
  config,
  lib,
  pkgs,
  ...
}:
{
  ## Terminal
  options.terminal = {
    default = lib.mkOption {
      type = lib.types.enum [ "ghostty" ];
      default = "ghostty";
      description = "Default terminal emulator";
    };
  };
  ## Shell
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
  ## Set Terminal
  home.packages = [ (pkgs.${config.opt.terminal.default}) ];
  environment.sessionVariables.TERMINAL = config.opt.terminal.default;
  ## Set Shell
  nushell.enable = config.opt.shell == "nushell";
  zsh.enable = config.opt.shell == "zsh";
}
