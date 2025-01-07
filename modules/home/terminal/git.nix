{ pkgs, ... }:
{
  programs.git = {
    enable = true;
    aliases = {
      # acp - automatically adds ., commits, pulls, then pushes to main.
      # Usage: git acp "commit message"
      acp = "!f() { git add . && git commit -m \"$@\" && git pull && git push; }; f";
    };
  };
}