/*{ flake, pkgs, ... }:
let
  inherit (flake) config inputs;
  inherit (inputs) self;
in
{
  imports = [
    # For NixOS
    inputs.spicetify-nix.nixosModules.default
    # For home-manager
    inputs.spicetify-nix.homeManagerModules.default
  ];
  programs.spicetify =
   let
     spicePkgs = inputs.spicetify-nix.legacyPackages.${pkgs.system};
   in
   {
     enable = true;
   };
}
*/
{}