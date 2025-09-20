## Just the place for all the little nice-to-have CLI tools
{ config
, lib
, pkgs
, ...
}:
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
      nh # nix-helper. https://github.com/nix-community/nh
      fd # better find
    ];

    programs = {
      bat.enable = true; # better `cat`
      fzf.enable = true; # Type `<ctrl> + r` to fuzzy search shell history
      btop = {
        enable = true;
        extraConfig = "update_ms = 500";
      };
      zoxide.enable = true; # <3 zoxide my beloved
    };
  };
}
