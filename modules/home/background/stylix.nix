{
  lib,
  config,
  flake,
  pkgs,
  ...
}:
let
  themes = {
    catppuccin-mocha = {
      scheme = "Catppuccin Mocha";
      base00 = "#1e1e2e"; # base
      base01 = "#181825"; # mantle
      base02 = "#313244"; # surface0
      base03 = "#5f6177"; # surface1
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
    catppuccin-latte = "${pkgs.base16-schemes}/share/themes/catppuccin-latte.yaml";
  };
  selectedTheme = themes.${config.theme.name};
in 
{
  config = {
    stylix = {
      enable = true;
      base16Scheme = selectedTheme;
      polarity = config.theme.polarity;
      cursor = {
        package = pkgs.bibata-cursors;
        name = "Bibata-Modern-Classic";
        size = 20;
      };
      image = config.theme.image;
      targets = {
        firefox.enable = true;
        firefox.profileNames = [ "textfox" ];
        spicetify.enable = false;
        vscode.profileNames = [ "default" ];
      };
    };
  };
}
