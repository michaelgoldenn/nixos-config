{ flake, ... }:
let
  inherit (flake) inputs;
  inherit (inputs) self;
in
{
  imports = [inputs.sops-nix.nixosModules.default];

  sops = {
  };
}