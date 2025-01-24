{ flake, pkgs, lib, ... }:
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
    ghostty.enable = true;
    terminal = {
      enable = true;
      default_shell = "nushell";
    };
  };
}
