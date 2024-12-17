{ flake, pkgs, ... }:
let
  inherit (flake) config inputs;
  inherit (inputs) self;
in
{
    # However you're currently installing Obsidian
    home.packages = [ pkgs.obsidian ];  # or however you're installing it

    # Add the systemd service
    systemd.user.services.obsidian = {
    Unit = {
      Description = "Obsidian";
      After = ["graphical-session.target"];
    };
    Service = {
      Environment = [
        "GITHUB_TOKEN=$(cat /run/secrets/github/obsidian)"
      ];
      ExecStart = "${pkgs.obsidian}/bin/obsidian";
    };
    Install = {
      WantedBy = ["graphical-session.target"];
    };
  };
}