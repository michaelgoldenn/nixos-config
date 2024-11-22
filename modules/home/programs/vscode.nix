{ flake, pkgs, ... }:
let
  inherit (flake) config inputs;
  inherit (inputs) self;
in
{
  programs.vscode = {
    enable = true;
    # wamt to find new vscode extensions? https://github.com/search good luck
    extensions = with pkgs.vscode-extensions; [
      # nix
      jnoortheen.nix-ide
      # rust
      bungcip.better-toml
      tamasfe.even-better-toml
    ];
    userSettings = {
      "explorer.confirmDelete" = false;
    };
  };
}