# This is your nixos configuration.
# For home configuration, see /modules/home/*
{ flake, pkgs, ... }:
{
  imports = [
    flake.inputs.self.nixosModules.common
    ./services
  ];
  nixpkgs.overlays = [
    flake.inputs.millennium.overlays.default
    # remove this later, needed to rebuild lutris as of April 2026
    (_: prev: {
      openldap = prev.openldap.overrideAttrs {
        doCheck = !prev.stdenv.hostPlatform.isi686;
      };
    })
  ];
  services.openssh = {
    enable = true;
    settings = {
      MaxAuthTries = 3;
      LoginGraceTime = 20;
    };
  };
  programs.nix-ld.enable = true; # enable nix ld for all PCs.

  # remove this later
  nixpkgs.config.permittedInsecurePackages = [
    "pnpm-10.29.2"
  ];

  # Allow SSH through the Cloudflare tunnel from any network
  environment.systemPackages = [ pkgs.cloudflared ];
  programs.ssh.extraConfig = ''
    Host ssh.michael-golden.org
      ProxyCommand ${pkgs.cloudflared}/bin/cloudflared access ssh --hostname %h
      User server
  '';
}
