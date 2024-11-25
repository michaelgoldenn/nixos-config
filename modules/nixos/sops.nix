{ flake, ... }:
let
  inherit (flake) inputs config;
  inherit (inputs) self;
in
{
  imports = [/* inputs.sops-nix.nixosModules.sops */ inputs.sops-nix.nixosModules.default];

/*   sops = {
    defaultSopsFile = ../../secrets/example.yaml;
    age = {
      keyFile = "/var/lib/sops-nix/key.txt";
      # Set this to false since we're providing our own key
      generateKey = false;
    };
    secrets."github/access_token" = { };
  }; */
}