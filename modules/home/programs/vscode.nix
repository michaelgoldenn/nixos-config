{ flake, pkgs, ... }:
let
  inherit (flake) config inputs;
  inherit (inputs) self;
  nix_settings = {
    "nix.enableLanguageServer" = true;
    "nix.serverPath" = "nixd";
    "nix.formatterPath" = "alejandra";
    "nix.serverSettings" = {
      "nixd" = {
        "formatting" = {
          "command" = ["alejandra"];
        };
      };
    };
  };
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
    }
    // nix_settings;
  };
}