{ flake, pkgs, ... }:
let
  inherit (flake) config inputs;
  inherit (inputs) self;
in
{
  home.packages = with pkgs; [ obsidian libsecret ];
/*    programs.obsidian = {
      enable = true;
      vaults = {
        obsidian-vault = {
          enable = true;
          path = "~/Documents/obsidian-vault";
        };
      };
    };
*/
}