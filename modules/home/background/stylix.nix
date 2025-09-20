{ lib, config, flake, pkgs, ... }:
{
  config = {
    stylix = {
      targets = {
        firefox.enable = true;
        firefox.profileNames = [ "textfox" ];
        spicetify.enable = false;
        vscode.profileNames = [ "default" ];
      };
    };
  };
}
