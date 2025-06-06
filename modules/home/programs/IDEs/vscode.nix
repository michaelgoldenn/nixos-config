# Actually uses VSCodium, just vscode without as much microsoft telemetry
{
  flake,
  pkgs,
  ...
}:
let
  inherit (flake) config inputs;
  inherit (inputs) self;
  cfg = config.mySystem;
  settings = {
    keyboard.dispatch = "keyCode";
    "nix" = {
      "enableLanguageServer" = true;
      "serverPath" = "nixd";
      "formatterPath" = "alejandra";
      "serverSettings" = {
        "nixd" = {
          "formatting" = {
            "command" = [ "nixfmt" ];
          };
        };
      };
    };
    "terminal.external.linuxExec" = "ghostty";
    "terminal.integrated.profiles.linux" = {
      "nu" = {
        "path" = "nu";
      };
    };
    "terminal.integrated.defaultProfile.linux" = "nu"; # Optional: to make nu the default
    # make it smooooth
    "editor.smoothScrolling" = true;
    "editor.cursorBlinking" = "smooth";
    "editor.cursorSmoothCaretAnimation" = "on";
    "workbench.list.smoothScrolling" = true;
    "terminal.integrated.smoothScrolling" = true;
    "terminal.integrated.cursorBlinking" = true;
  };
in
{
  programs.vscode = {
    enable = true;
    package = pkgs.vscodium;
    # want to find new vscode extensions? https://github.com/search?q=language%3ANix+vscode-extensions&type=code good luck
    # maybe try getting new ones like this: 1. Find extension on marketplace. 2. Click gear -> "Copy Extension ID". 3. Paste it in here
    profiles = {
      default = {
        extensions =
          with pkgs.vscode-extensions;
          [
            # general
            usernamehw.errorlens
            # nix
            jnoortheen.nix-ide
            mkhl.direnv
            # rust
            rust-lang.rust-analyzer
            vadimcn.vscode-lldb
            tamasfe.even-better-toml
            # python
            ms-python.python
          ]
          ++ pkgs.vscode-utils.extensionsFromVscodeMarketplace [
            # or can add new extensions here if easier
            # github actions
            {
              name = "github-local-actions";
              publisher = "sanjulaganepola";
              version = "1.2.5";
              sha256 = "sha256-gc3iOB/ibu4YBRdeyE6nmG72RbAsV0WIhiD8x2HNCfY=";
            }
            # godot
            {
              name = "godot-tools";
              publisher = "geequlim";
              version = "2.5.1";
              sha256 = "sha256-iuSec4PoVxyu1KB2jfCYOd98UrqQjH3q24zOR4VCPgs=";
            }
            {
              name = "gdshader-lsp";
              publisher = "godofavacyn";
              version = "1.0.7";
              sha256 = "sha256-NMGIijmTb9DNgEKvQdaIeWt688ztZjgte8m2ZPMg8r4=";
            }
          ];
        userSettings = {
          "explorer.confirmDelete" = false;
          "godotTools.editorPath.godot4" = "/run/current-system/etc/profiles/per-user/michael/bin/godot4";
          "git.autofetch" = true;
        } // settings;
      };
    };
  };
}
