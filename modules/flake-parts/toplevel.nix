# Top-level flake glue to get our configuration working
{ inputs, ... }:

{
  imports = [
    inputs.nixos-unified.flakeModules.default
    inputs.nixos-unified.flakeModules.autoWire
    ./networking.nix  # Import our new networking module
  ];
  
  perSystem = { self', pkgs, ... }: {
    # For 'nix fmt'
    formatter = pkgs.nixpkgs-fmt;

    # Enables 'nix run' to activate.
    packages.default = self'.packages.activate;
    
    # The default network interface for the system
    networkingConfig = {
      primaryInterface = "enp3s0";  # default value
    };
  };
}