{ flake, ... }:
let
  inherit (flake) config inputs;
  inherit (inputs) self;
in
{
  imports = [
    flake.inputs.stylix.nixosModules.stylix
  ];
  stylix = {
    enable = true;
    image = ./wallpaper.png;
    polarity = "dark";
    cursor.size = 320;
  };
}