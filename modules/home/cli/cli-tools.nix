## Just the place for all the little nice-to-have CLI tools
{ pkgs, ... }:
{

  home.packages = with pkgs; [
    ripgrep # better grep
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
}
