{ pkgs, ... }:
{
  programs.git = {
    enable = true;
    aliases = {
      # acp - automatically adds ., commits, pulls, then pushes to main.
      acp = "!f() { git add . && git commit -m \"$@\" && git pull && git push; }; f";
    };
  };
}