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
  };
}
