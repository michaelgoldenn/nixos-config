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
      bbenoist.nix
      # rust
      bungcip.better-toml
      tamasfe.even-better-toml
    ];
    userSettings = {
      "explorer.confirmDelete" = false;
    };
  };
}