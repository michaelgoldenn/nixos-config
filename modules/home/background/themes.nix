{ lib, ... }:
let
  inherit (lib) mkOption types;
in
{
  options.theme = {
    name = mkOption {
      type = types.enum [ "catppuccin-mocha" "catppuccin-latte" ];
      default = "catppuccin-mocha";
      description = "Theme to use across the system";
    };
    polarity = mkOption {
      type = types.enum [ "dark" "light" ];
      default = "dark";
      description = "Whether to use light or dark mode";
    };
  };
}
