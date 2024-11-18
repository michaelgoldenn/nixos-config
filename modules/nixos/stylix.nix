{ flake, ... }:
let
  inherit (flake) config inputs;
  inherit (inputs) self;
in
{
  stylix = {
    enable = true;
    image = /home/michael/Downloads/thank_you_wallpaper.png;
    cursor.size = 320
  };
}