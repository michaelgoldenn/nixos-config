{ flake, pkgs, ... }:
let
  inherit (flake) config inputs;
  inherit (inputs) self;
in
{
    home.packages = with pkgs; [ obsidian libsecret ];
    # Setup obisdian-git:
    # https://publish.obsidian.md/git-doc/Authentication

}