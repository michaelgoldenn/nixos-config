{ flake, ... }:
let
  inherit (flake) config inputs;
  inherit (inputs) self;
in
{
  #stylix.targets.xyz.enable = false;
  stylix = {
    enable = true;
    targets = {
      firefox.enable = true;
      firefox.profileNames = [ "textfox" ];
      spicetify.enable = false;
      vscode.profileNames = [ "default" ];
    };
  };
}
