{flake, pkgs, lib, ...}:
{
  environment.systemPackages = with pkgs; [
    #neovide
  ];
}