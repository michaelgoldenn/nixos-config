{ flake, ... }:
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
  theme.name = "catppuccin-mocha";

  home.stateVersion = "24.11";
}
