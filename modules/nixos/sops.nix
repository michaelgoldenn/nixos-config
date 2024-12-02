{ flake, pkgs, config, ... }:
let
  inherit (flake) inputs;
  inherit (inputs) self;
in
{ 
  # to add a new computer, run `mkdir -p ~/.config/sops/age`, then `age-keygen -o ~/.config/sops/age/keys.txt`.
  # then do `age-keygen -y ~/.config/sops/age/keys.txt` and paste the output into ../../.sops.yaml

  # To edit the code, just run `sops /etc/nixos/.sops.yaml`

  imports = [inputs.sops-nix.nixosModules.sops inputs.sops-nix.nixosModules.default];
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