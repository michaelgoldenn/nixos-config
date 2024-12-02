{ flake, pkgs, config, ... }:
let
  inherit (flake) inputs;
  inherit (inputs) self;
in
{
  imports = [/* inputs.sops-nix.nixosModules.sops */ inputs.sops-nix.nixosModules.default];
  environment.systemPackages =  with pkgs; [ pinentry-curses ];
  sops = {
    defaultSopsFile = ../../secrets/example.yaml;
    age = {
      keyFile = "/home/michael/.config/sops/age/keys.txt";
      # Set this to false since we're providing our own key
      generateKey = true;
    };
    secrets = {
      "github/access_token" = {
        mode = "0440";
        owner = config.users.users.michael.name;
       };
    };
  };
}