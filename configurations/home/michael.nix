{
  flake,
  pkgs,
  lib,
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
  home.username = "michael";
  home.homeDirectory = lib.mkDefault "/${if pkgs.stdenv.isDarwin then "Users" else "home"}/michael";
  home.stateVersion = "22.11";

  opt = {
    terminal.default = "ghostty";
    shell.default = "nushell";
    making-games.enable = true;
    hyprland.enable = true;
  };
}
