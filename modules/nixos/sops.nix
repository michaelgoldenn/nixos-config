{ flake, pkgs, config, ... }:
let
  inherit (flake) inputs;
  inherit (inputs) self;
in
{ 
  # to add a new computer, run `mkdir -p ~/.config/sops/age`, then `age-keygen -o ~/.config/sops/age/keys.txt`.
  # then do `age-keygen -y ~/.config/sops/age/keys.txt` and put the output into ../../.sops.yaml
  # then I think you need to run `nix-shell -p sops --run "sops updatekeys secrets/example.yaml"`

  # To add a new secret, just run `nix-shell -p sops --run "sops /etc/nixos/.sops.yaml"`and add it where you want

  imports = [inputs.sops-nix.nixosModules.sops /* inputs.sops-nix.nixosModules.default */];
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