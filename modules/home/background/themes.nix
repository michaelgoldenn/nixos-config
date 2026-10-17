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

  # Hard edges: no rounding, thick accent borders, no blur or shadow. Shared by both
  # Mirror's Edge variants.
  edgeStyle = {
    rounding = 0;
    borderSize = 4;
    gapsIn = 4;
    gapsOut = 4;
    blur = false;
    shadow = false;
    animations = false;
    cornerScale = 0.0;
    barColor = "base08";
    activeBorder = "base08";
    inactiveBorder = "base02";
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

    mirrors-edge = {
      polarity = "light";
      style = edgeStyle;
      image = pkgs.fetchurl {
        url = "https://archive.mirrorsedgearchive.org/Mirror's%20Edge%20Catalyst%20(2016)/Official%20Wallpapers/ME_Wallpaper_16x9_1920x1080_02.jpg";
        hash = "sha256-uR7KRwSnDCCWTjQYuz4ZC8pJK465ESu6LHUjRx+5G5w=";
      };
      swatch = [
        "#f2f2f0"
        "#1a1a1a"
        "#e8281e"
        "#f28c00"
        "#0fa3b8"
        "#1a6fd6"
      ];
      scheme = {
        scheme = "Mirror's Edge";
        base00 = "#f2f2f0";
        base01 = "#e6e6e3";
        base02 = "#d4d4d0";
        base03 = "#8a8a86";
        base04 = "#55554f";
        base05 = "#1a1a1a";
        base06 = "#111111";
        base07 = "#000000";
        base08 = "#e8281e"; # red
        base09 = "#f28c00"; # orange
        base0A = "#c99700"; # yellow, darkened to hold contrast on white
        base0B = "#2e9e4f"; # green
        base0C = "#0fa3b8"; # cyan
        base0D = "#1a6fd6"; # blue
        base0E = "#7a3fc4"; # purple
        base0F = "#a8421e"; # brown
      };
    };

    mirrors-edge-night = {
      polarity = "dark";
      style = edgeStyle;
      image = pkgs.fetchurl {
        url = "https://archive.mirrorsedgearchive.org/Mirror's%20Edge%20Catalyst%20(2016)/Official%20Wallpapers/ME_Wallpaper_16x9_1920x1080_02.jpg";
        hash = "sha256-uR7KRwSnDCCWTjQYuz4ZC8pJK465ESu6LHUjRx+5G5w=";
      };
      swatch = [
        "#141618"
        "#ececec"
        "#ff3b30"
        "#ffa21a"
        "#2fd5ea"
        "#3d8bff"
      ];
      scheme = {
        scheme = "Mirror's Edge Night";
        base00 = "#141618";
        base01 = "#1c1f21";
        base02 = "#2a2d30";
        base03 = "#6b7075";
        base04 = "#9aa0a5";
        base05 = "#ececec";
        base06 = "#f5f5f5";
        base07 = "#ffffff";
        base08 = "#ff3b30";
        base09 = "#ffa21a";
        base0A = "#ffd60a";
        base0B = "#3ddc84";
        base0C = "#2fd5ea";
        base0D = "#3d8bff";
        base0E = "#b07cff";
        base0F = "#ff7a59";
      };
    };

    everforest = {
      polarity = "dark";
      scheme = "${pkgs.base16-schemes}/share/themes/everforest.yaml";
      image = pkgs.fetchurl {
        url = "https://box.apeiros.xyz/public/everforest_walls/nature/fog_forest_1.png";
        hash = "sha256-wQxWI0FNc37mvRO4zV123NXG50XOO6qKv7J8IKIxgmo=";
      };
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

  styleType = types.submodule {
    options = {
      rounding = mkOption {
        type = types.int;
        default = 20;
        description = "Window corner radius in pixels.";
      };
      borderSize = mkOption {
        type = types.int;
        default = 2;
        description = "Window border thickness in pixels.";
      };
      gapsIn = mkOption {
        type = types.int;
        default = 5;
        description = "Gap between windows.";
      };
      gapsOut = mkOption {
        type = types.int;
        default = 10;
        description = "Gap between windows and screen edges.";
      };
      blur = mkOption {
        type = types.bool;
        default = true;
        description = "Blur behind windows and noctalia panels.";
      };
      shadow = mkOption {
        type = types.bool;
        default = true;
        description = "Window drop shadows.";
      };
      animations = mkOption {
        type = types.bool;
        default = true;
        description = "Hyprland animations.";
      };
      cornerScale = mkOption {
        type = types.float;
        default = 1.0;
        description = "noctalia's corner_radius_scale: 0 is square, 1 is default.";
      };
      barColor = mkOption {
        type = types.nullOr types.str;
        default = null;
        example = "base08";
        description = ''
          Base16 slot to fill the noctalia bar with, with white icons and labels on top.
          Null leaves the bar on the palette's surface colour.
        '';
      };
      activeBorder = mkOption {
        type = types.nullOr types.str;
        default = null;
        example = "base08";
        description = "Base16 slot for the focused window border. Null keeps stylix's choice.";
      };
      inactiveBorder = mkOption {
        type = types.nullOr types.str;
        default = null;
        example = "base02";
        description = "Base16 slot for unfocused window borders. Null keeps stylix's choice.";
      };
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
        style = mkOption {
          type = styleType;
          default = { };
          description = "Window geometry and effects, applied alongside the colours.";
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
