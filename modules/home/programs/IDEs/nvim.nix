{
  flake,
  lib,
  config,
  inheritedConfig,
  pkgs,
  ...
}:
let
  inherit (flake) config inputs;
  inherit (inputs) self;
in
{
  imports = [ inputs.nixvim.homeManagerModules.nixvim ];
  programs.nixvim = {
    enable = true;
    plugins = {
      lsp = {
        enable = true;
        servers = {
          rust_analyzer = {
            enable = true;
            installCargo = false;
            installRustc = false;
          };
        };
      };
    };
  };
}
