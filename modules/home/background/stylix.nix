{ lib, config, flake, ... }:
let
  inherit (lib) mkOption types;
  
  # Define your themes here (same as in NixOS module)
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
    catppuccin-frappe = {
      scheme = "Catppuccin Frappe";
      # Add frappe colors here
      base00 = "#303446"; # base
      base01 = "#292c3c"; # mantle
      # ... etc
    };
    equilibrium-dark = {
      scheme = "Equilibrium Dark";
      # Add equilibrium colors here
    };
  };
  
  selectedTheme = themes.${config.theme.name};
in
{
  imports = [
    flake.inputs.stylix.homeModules.stylix
  ];
  config = {
    stylix = {
      enable = true;
      base16Scheme = selectedTheme;  # Set the scheme based on selected theme
      targets = {
        firefox.enable = true;
        firefox.profileNames = [ "textfox" ];
        spicetify.enable = false;
        vscode.profileNames = [ "default" ];
      };
    };
  };
}