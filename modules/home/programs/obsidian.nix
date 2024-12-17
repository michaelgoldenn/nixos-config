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
      ExecStart = "${pkgs.writeShellScript "obsidian-wrapper" ''
        TOKEN=$(cat /run/secrets/github/obsidian)
        export GITHUB_TOKEN=$TOKEN
        export GH_TOKEN=$TOKEN
        export GITHUB_ACCESS_TOKEN=$TOKEN
        export GIT_CREDENTIALS=$TOKEN
        export GIT_ACCESS_TOKEN=$TOKEN
        exec ${pkgs.obsidian}/bin/obsidian
      ''}";
    };
    Install = {
      WantedBy = ["graphical-session.target"];
    };
  };
}