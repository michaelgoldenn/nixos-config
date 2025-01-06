{ pkgs, ... }:
{
  programs.git = {
    enable = true;
    config = {
      alias = {
        acp = "!f() { git add . && git commit -m \"$@\" && git push; }; f";
      };
    };
  };
}