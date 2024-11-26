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
      firefox.profileNames = ["textfox" "normal"];
      nushell.enable = true;
    };
  };
}