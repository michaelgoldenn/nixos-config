{
  flake,
  pkgs,
  ...
}: let
  inherit (flake) config inputs;
  inherit (inputs) self;
  settings = {
    "nix" = {
      "enableLanguageServer" = true;
      "serverPath" = "nixd";
      "formatterPath" = "alejandra";
      "serverSettings" = {
        "nixd" = {
          "formatting" = {
            "command" = ["alejandra"];
          };
        };
      };
    };
    "terminal.external.linuxExec" = "foot";
    "terminal.integrated.profiles.linux" = {
      "nu" = {
        "path" = "nu";
      };
    };
    "terminal.integrated.defaultProfile.linux" = "nu"; # Optional: to make nu the default
  };
in {
  programs.vscode = {
    enable = true;
    # want to find new vscode extensions? https://github.com/search?q=language%3ANix+vscode-extensions&type=code good luck
    # maybe try getting new ones like this: 1. Find extension on marketplace. 2. Click gear -> "Copy Extension ID". 3. Paste it in here
    extensions = with pkgs.vscode-extensions;
      [
        # nix
        jnoortheen.nix-ide
        # rust
        tamasfe.even-better-toml
        rust-lang.rust-analyzer
        formulahendry.code-runner
      ]
      ++ pkgs.vscode-utils.extensionsFromVscodeMarketplace [
        # or can add new extensions here if easier
        # godot
        {
          name = "godot-tools";
          publisher = "geequlim";
          version = "2.3.0";
          sha256 = "sha256-iuSec4PoVxyu1KB2jfCYOd98UrqQjH3q24zOR4VCPgs=";
        }
        {
          name = "gdshader-lsp";
          publisher = "godofavacyn";
          version = "1.0.7";
          sha256 = "sha256-NMGIijmTb9DNgEKvQdaIeWt688ztZjgte8m2ZPMg8r4=";
        }
      ];
    userSettings =
      {
        "explorer.confirmDelete" = false;
        "godotTools.editorPath.godot4" = "/run/current-system/etc/profiles/per-user/michael/bin/godot4";
        "git.autofetch" = true;
      }
      // settings;
  };
}
