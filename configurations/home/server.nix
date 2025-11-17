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
    username = "server";
    fullname = "Michaels Server";
    email = "Michael.Golden0278@gmail.com";
  };

  cliTools.enable = true;
  vscode.enable = true;
  shell.default = "nushell"; # defined in modules/home/cli/terminal/default.nix
  helix.enable = true;
  kdeconnect.enable = true;
  business.enable = true;

  # styling
  theme.name = "catppuccin-mocha";
  theme.polarity = "dark";
  theme.monoFont = "mapleMono";

  home.stateVersion = "24.11";
}
