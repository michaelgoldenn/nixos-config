## The theme registry.
##
## To add a theme: add an attribute below (scheme gallery is at
## https://tinted-theming.github.io/tinted-gallery/) and rebuild. Everything else follows.
{
  lib,
  config,
  pkgs,
  ...
}:
let
  inherit (lib) mkOption types;

  # Wallpapers come from https://github.com/orangci/walls.
  # `nix-prefetch-url <url>` then `nix hash convert --to sri sha256:<hash>` to add one.
  wall =
    file: hash:
    pkgs.fetchurl {
      url = "https://raw.githubusercontent.com/orangci/walls/refs/heads/master/${file}";
      inherit hash;
    };

  themes = {
    catppuccin-mocha = {
      polarity = "dark";
      image = wall "isekai.jpg" "sha256-PoOg8v5+Zkjf8hz7GvH8paCC29BcyHePgeXMghv9Zpo=";
      swatch = [
        "#1e1e2e"
        "#cdd6f4"
        "#f38ba8"
        "#a6e3a1"
        "#89b4fa"
        "#cba6f7"
      ];
      # Spelled out rather than taken from base16-schemes so the greys can be tweaked.
      scheme = {
        scheme = "Catppuccin Mocha";
        base00 = "#1e1e2e"; # base
        base01 = "#181825"; # mantle
        base02 = "#313244"; # surface0
        base03 = "#65677d"; # surface1
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
    };

    everforest = {
      polarity = "dark";
      scheme = "${pkgs.base16-schemes}/share/themes/everforest.yaml";
      image = wall "greenbus.jpg" "sha256-abaiBjgh/wCvpcuChZpvI+RLBHogQNv8aLgAnRyUb+M=C";
      swatch = [
        "#2d353b"
        "#d3c6aa"
        "#e67e80"
        "#a7c080"
        "#7fbbb3"
        "#d699b6"
      ];
    };
  };

  themeType = types.submodule (
    { name, ... }:
    {
      options = {
        scheme = mkOption {
          type = types.either types.str (types.attrsOf types.str);
          description = "A base16 scheme: either a path to a .yaml scheme or the colours inline.";
        };
        polarity = mkOption {
          type = types.enum [
            "dark"
            "light"
          ];
          description = "Whether this theme is a light or a dark one.";
        };
        image = mkOption {
          type = types.path;
          description = "Wallpaper to show while this theme is active.";
        };
        swatch = mkOption {
          type = types.listOf types.str;
          default = [ ];
          example = [
            "#1e1e2e"
            "#cdd6f4"
          ];
          description = ''
            A handful of representative hex colours, drawn as a colour bar in the
            `theme` picker. Purely cosmetic; ${name} works fine without it.
          '';
        };
      };
    }
  );
in
{
  options.theme = {
    themes = mkOption {
      type = types.attrsOf themeType;
      default = themes;
      description = "Every theme available to switch between.";
    };
    name = mkOption {
      type = types.str;
      default = "catppuccin-mocha";
      description = "Which entry of `theme.themes` to wear. Must be one of its attribute names.";
    };
    selected = mkOption {
      type = themeType;
      readOnly = true;
      internal = true;
      description = "The resolved `theme.themes.<theme.name>`, for other modules to read.";
    };
    polarity = mkOption {
      type = types.enum [
        "dark"
        "light"
      ];
      description = "Whether to use light or dark mode. Defaults to the selected theme's polarity.";
    };
    image = mkOption {
      type = types.path;
      description = "Wallpaper to use. Defaults to the selected theme's wallpaper.";
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

  config = {
    assertions = [
      {
        assertion = config.theme.themes ? ${config.theme.name};
        message =
          "theme.name is set to '${config.theme.name}', which is not in theme.themes. "
          + "Known themes: ${lib.concatStringsSep ", " (lib.attrNames config.theme.themes)}.";
      }
    ];

    theme = {
      selected = config.theme.themes.${config.theme.name};
      # mkDefault so a single theme can still be overridden piecemeal, e.g. to keep a
      # dark palette but try a different wallpaper.
      polarity = lib.mkDefault config.theme.selected.polarity;
      image = lib.mkDefault config.theme.selected.image;
    };
  };
}
