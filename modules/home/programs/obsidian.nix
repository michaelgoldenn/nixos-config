{ flake, pkgs, ... }:
let
  inherit (flake) config inputs;
  inherit (inputs) self;
in
{
    # However you're currently installing Obsidian
    home.packages = with pkgs; [ obsidian ];  # or however you're installing it

    # Add the systemd service

}