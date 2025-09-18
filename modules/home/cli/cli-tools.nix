## Just the place for all the little nice-to-have CLI tools
{ config, lib, pkgs, ... }:
{
  options.cliTools.enable = lib.mkOption {
    type = lib.types.bool;
    default = true;
    description = "Basic CLI tools";
  };

  config = lib.mkIf config.cliTools.enable {
    home.packages = with pkgs; [
      ripgrep # better grep
      cookiecutter # makes files from templates (python eww, pls RIIR)
    ];
    programs = {
      # Better `cat`
      bat.enable = true;
      # Type `<ctrl> + r` to fuzzy search your shell history
      fzf.enable = true;
      jq.enable = true;
      # Install btop https://github.com/aristocratos/btop
      btop.enable = true;
    };
  };
}