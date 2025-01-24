{config, lib, pkgs, ...}:
let
  name = "terminal";
  cfg = config.opt.${name};
in
{
  options.opt.${name} = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Enables ${name}";
    };
    
    default_shell = lib.mkOption {
      type = lib.types.enum [ "nushell" "zsh" ];
      default = "nushell";
      description = "Default shell to use";
    };
  };

  # auto-import
  imports =
    with builtins;
    map
      (fn: ./${fn})
      (filter (fn: fn != "default.nix") (attrNames (readDir ./.)));

  config = lib.mkIf cfg.enable {
    opt = {
      nushell.enable = cfg.default_shell == "nushell";
      zsh.enable = cfg.default_shell == "zsh";
    };
  };
}