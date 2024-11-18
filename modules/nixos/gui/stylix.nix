{ flake, ... }:
let
  inherit (flake) config inputs;
  inherit (inputs) self;
in
{
  stylix.enable = true;
  stylix.image = /home/michael/Downloads/thank_you_wallpaper.png;
}