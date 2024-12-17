{ flake, pkgs, ... }:
let
  inherit (flake) config inputs;
  inherit (inputs) self;
in
{
    # However you're currently installing Obsidian
    home.packages = with pkgs; [ obsidian libsecret ];  # or however you're installing it

    # Add the systemd service
  systemd.user.services.obsidian = {
    Unit = {
      Description = "Obsidian";
      After = ["graphical-session.target"];
    };
    Service = {
      # Set up git config before starting Obsidian
      ExecStartPre = "${pkgs.writeShellScript "git-config-setup" ''
        ${pkgs.git}/bin/git config --global credential.helper libsecret
      ''}";
      ExecStart = "${pkgs.obsidian}/bin/obsidian";
    };
    Install = {
      WantedBy = ["graphical-session.target"];
    };
  };
}