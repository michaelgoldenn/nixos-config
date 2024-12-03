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
    # wamt to find new vscode extensions? https://github.com/search?q=language%3ANix+vscode-extensions&type=code good luck
    extensions = with pkgs.vscode-extensions; [
      # nix
      jnoortheen.nix-ide
      # rust
      tamasfe.even-better-toml
      rust-lang.rust-analyzer
      # godot
    ] ++ pkgs.vscode-utils.extensionsFromVscodeMarketplace [
      {
        name = "godot-tools";
        publisher = "geequlim";
        version = "2.3.0";
        sha256 = "sha256-iuSec4PoVxyu1KB2jfCYOd98UrqQjH3q24zOR4VCPgs=";
      }
    ];
    userSettings = {
      "explorer.confirmDelete" = false;
      "godotTools.editorPath.godot4" = "/run/current-system/etc/profiles/per-user/michael/bin/godot4";
      "git.autofetch" = true;
    }
    // nix_settings;
  };
}