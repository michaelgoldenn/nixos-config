{
  lib,
  config,
  flake,
  pkgs,
  ...
}@args:
let
  # have to do the strange `args` shenanigans to check if we're building in hm or nixos, was getting problems before
  isNixOS = args ? osConfig;
  fonts = {
    # non-mono fonts
    dejavu = {
      package = pkgs.dejavu_fonts;
      name = "DejaVu Sans";
    };
    # mono fonts
    dejavuMono = {
      package = pkgs.dejavu_fonts;
      name = "DejaVu Sans Mono";
    };
    jetbrainsMono = {
      package = pkgs.nerd-fonts.jetbrains-mono;
      name = "JetBrainsMono Nerd Font";
    };
    mapleMono = {
      # https://github.com/subframe7536/Maple-font
      package = pkgs.maple-mono.NF-unhinted;
      name = "MapleMonoNF";
    };
  };
  # The palette/polarity/wallpaper all come from the registry in ./themes.nix
  selectedMonoFont = fonts.${config.theme.monoFont};
  selectedNormalFont = fonts.${config.theme.normalFont};

in
{
  # only import stylix if we're building in home-manager mode.
  imports = lib.optionals (!isNixOS) [
    flake.inputs.stylix.homeModules.stylix
  ];
  # currently don't have an option for stylix, should probably add one.
  config = {
    stylix = {
      enable = true;
      base16Scheme = lib.mkForce config.theme.selected.scheme;
      polarity = config.theme.polarity;
      image = config.theme.image;
      cursor = {
        package = pkgs.bibata-cursors;
        name = "Bibata-Modern-Classic";
        size = 20;
      };
      fonts.monospace = selectedMonoFont;
      targets = {
        firefox = {
          enable = true;
          colorTheme.enable = true;
          profileNames = [
            "textfox"
            "normal"
          ];
        };
        spicetify.enable = false;
        vscode.profileNames = [ "default" ];
      };
    };
  };
}
