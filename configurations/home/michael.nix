{
  flake,
  pkgs,
  config,
  ...
}:
let
  inherit (flake) inputs;
  inherit (inputs) self;
in
{
  imports = [
    self.homeModules.default
  ];

  # Defined by /modules/home/me.nix
  # And used all around in /modules/home/*
  me = {
    username = "michael";
    fullname = "Michael Golden";
    email = "Michael.Golden0278@gmail.com";
  };

  cliTools.enable = true;
  vscode.enable = true;
  shell.default = "nushell"; # defined in modules/home/cli/terminal/default.nix
  helix.enable = true;
  gaming.enable = true;
  nixcord.enable = true;
  vesktop.enable = false;
  spotify.enable = true;
  making_games.enable = true;
  kdeconnect.enable = true;
  obsidian.enable = true;
  printing_3d.enable = true; # 3d printing things
  pentesting.enable = true;
  video_editing.enable = true;
  business.enable = true;
  calibre.enable = true;

  # styling
  theme.name = "catppuccin-mocha";
  theme.polarity = "dark";
  theme.monoFont = "mapleMono";

  nixpkgs.config.allowUnfree = true; # need to set this everywhere I can to avoid the unfree warnings
  home.stateVersion = "24.11";
}
