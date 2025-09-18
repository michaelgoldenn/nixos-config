{ flake, lib, pkgs, ... }:
let
  inherit (flake) config inputs;
  inherit (inputs) self;
in
{
  imports = [
    flake.inputs.stylix.nixosModules.stylix
  ];
  home-manager.backupFileExtension = "backup"; # need this otherwise stylix runs into other configs and breaks Home Manager
  stylix = {
    enable = true;

    image = pkgs.fetchurl {
      url = "https://raw.githubusercontent.com/orangci/walls/refs/heads/main/isekai.jpg";
      sha256 = "sha256-PoOg8v5+Zkjf8hz7GvH8paCC29BcyHePgeXMghv9Zpo=";
    };
    #image = selectedWallpaper;
    # themes defined here: https://tinted-theming.github.io/base16-gallery/
    #base16Scheme = "${pkgs.base16-schemes}/share/themes/catppuccin-mocha.yaml";
    base16Scheme = { # overwriting specific colors
      scheme = "Catppuccin Mocha";
      base00 = "#1e1e2e"; # base
      base01 = "#181825"; # mantle
      base02 = "#313244"; # surface0
      base03 = "#5f6177"; # surface1: code comments (brighened slightly)
      base04 = "#585b70"; # surface2
      base05 = "#cdd6f4"; # text
      base06 = "#f5e0dc"; # rosewater
      base07 = "#b4befe"; # lavender
      base08 = "#f38ba8"; # red
      base09 = "#fab387"; # peach
      base0A = "#f9e2af"; # yellow
      base0B = "#a6e3a1"; # green
      base0C = "#94e2d5"; # teal
      base0D = "#89b4fa"; # blue
      base0E = "#cba6f7"; # mauve
      base0F = "#f2cdcd"; # flamingo
    };
    /* Themes I've tried:
    catpucchin-frappe - comments are kinda hard to read
    equilibrium-dark - too contrasty, rust code is all super saturated yellow and red

    DO NOT USE:
    brogrammer
    dracula
    */
    polarity = "dark";
    cursor = {
      package = pkgs.bibata-cursors;
      name = "Bibata-Modern-Classic";
      size = 20;
    };
  };
}