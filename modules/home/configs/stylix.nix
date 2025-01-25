{ flake, ... }:
let
  inherit (flake) config inputs;
  inherit (inputs) self;
in
{
  #stylix.targets.xyz.enable = false;
  stylix = {
    enable = false;
    targets = {
      #firefox.profileNames = ["textfox" "normal"];
      firefox.enable = false;
      spicetify.enable = true;
    };
  };
}