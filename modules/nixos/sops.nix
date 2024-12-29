{ flake, pkgs, config, ... }:
let
  inherit (flake) inputs;
  inherit (inputs) self;
in
{ 
  ## Adding new host:
  # 1. Create Key: `mkdir ~/.config/sops/age` then `age-keygen -o ~/.config/sops/age/keys.txt`
  # 2. Add Key to system: `age-keygen -y ~/.config/sops/age/keys.txt` then put the output into `.sops.yaml`
  # 3. Push that sucker to github, then on a machine that is already working, run `nix-shell -p sops --run "sops updatekeys secrets/secrets.yaml"`
  # 4. Push from the other mahcine, pull from new machine, and `just run`

  ## Adding new secret:
  # nix-shell -p sops --run "sops /etc/nixos/secrets/secrets.yaml"
    # or `just sops`
  # Then add the new key to the bottom of this file
  # Then just rebuild and you should be good


  imports = [inputs.sops-nix.nixosModules.sops /* inputs.sops-nix.nixosModules.default */];
  environment.systemPackages =  with pkgs; [ pinentry-curses ];
  sops = {
    defaultSopsFile = ../../secrets/secrets.yaml;
    age = {
      keyFile = "/home/michael/.config/sops/age/keys.txt";
      # Set this to false since we're providing our own key
      generateKey = true;
    };
    secrets = {
      # I should really find if I can automatically set the owner and mode for all of them, instead of each individually
      "github/nixos" = {
        mode = "0440";
        owner = config.users.users.michael.name;
       };
      "github/support-coop-game" = {
        mode = "0440";
        owner = config.users.users.michael.name;
       };
      "github/portal-game" = {
        mode = "0440";
        owner = config.users.users.michael.name;
       };
      "github/obsidian" = {
        mode = "0440";
        owner = config.users.users.michael.name;
      };
      "github/infinity-game" = {
        mode = "0440";
        owner = config.users.users.michael.name;
      };
      "github/kartoffels-bot" = {
        mode = "0440";
        owner = config.users.users.michael.name;
      };
      "anytype" = {
        mode = "0440";
        owner = config.users.users.michael.name;
      };
    };
  };
}