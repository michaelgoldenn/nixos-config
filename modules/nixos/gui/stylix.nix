{ flake, pkgs, ... }:
let
  inherit (flake) config inputs;
  inherit (inputs) self;
in
{
# temp steam stuff, delet later
  imports = [
    flake.inputs.stylix.nixosModules.stylix
  ];
  stylix = {
    enable = true;
/*     image = pkgs.fetchurl {
      url = "https://www.pixelstalk.net/wp-content/uploads/2016/05/Epic-Anime-Awesome-Wallpapers.jpg";
      sha256 = "enQo3wqhgf0FEPHj2coOCvo7DuZv+x5rL/WIo4qPI50=";
    }; */
    image = ./wallpaper.png;
    polarity = "dark";
  };
}