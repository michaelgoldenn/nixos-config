{ pkgs, ... }:
{
  programs.git = {
    enable = true;
    aliases = {
      acp = "!f() { git add . && git commit -m \"$@\" && git push; }; f";
    };
  };
}