{config, lib, pkgs, ...}:
let
  name = "shell";
  cfg = config.opt.${name};
in
{
  options.opt.${name} = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Enables ${name}";
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

  config = lib.mkIf cfg.enable {
    opt = {
      nushell.enable = cfg.default == "nushell";
      zsh.enable = cfg.default == "zsh";
    };
  };
}