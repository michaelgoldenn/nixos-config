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
    image = /home/michael/Downloads/thank_you_wallpaper.png;
    polarity = "dark";
    cursor.size = 320;
  };
}