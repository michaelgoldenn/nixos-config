{ lib, pkgs, ... }:
let
  inherit (lib) mkOption types;
in
{
  options.theme = {
    name = mkOption {
      type = types.enum [
        "catppuccin-mocha"
        "catppuccin-latte"
      ];
      default = "catppuccin-mocha";
      description = "Theme to use across the system";
    };
    polarity = mkOption {
      type = types.enum [
        "dark"
        "light"
      ];
      default = "dark";
      description = "Whether to use light or dark mode";
    };
    image = mkOption {
      default = pkgs.fetchurl {
        url = "https://raw.githubusercontent.com/orangci/walls/refs/heads/master/isekai.jpg";
        sha256 = "sha256-PoOg8v5+Zkjf8hz7GvH8paCC29BcyHePgeXMghv9Zpo=";
      };
    };
    monoFont = mkOption {
      type = types.enum [
        "dejavuMono"
        "jetbrainsMono"
        "mapleMono"
      ];
      default = "dejavuMono";
      description = "Which font to use in code editors";
    };
    normalFont = mkOption {
      type = types.enum [
        "dejavu"
        "jetbrains"
        "maple"
      ];
      default = "dejavu";
      description = "Primary non-monospaced font to use";
    };
  };
}
