{ flake, pkgs, ... }:
let
  inherit (flake) config inputs;
  inherit (inputs) self;
in
{
/*   imports = [inputs.nixcord.homeManagerModules.nixcord];
  programs.nixcord = {
    enable = true;  # also install discord
    quickCss = "";
    config = {
      useQuickCss = true;
      themeLinks = [
        "https://raw.githubusercontent.com/link/to/some/theme.css"
      ];
      # Vencord options: https://github.com/KaylorBen/nixcord/blob/main/docs/vencord.md
      frameless = true;

      # Plugin Options: https://github.com/KaylorBen/nixcord/blob/main/docs/plugins.md
      plugins = {
        alwaysTrust = {
          enable = true;
          domain = true;
          file = true;
        };
      };
    };
    extraConfig = {
      # Some extra JSON config here
      # ...
    };
  }; */
/*   home.packages = with pkgs; [
    vesktop
  ]; */
}