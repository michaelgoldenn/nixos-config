{flake, pkgs, lib, ...}:
{
  environment.systemPackages = with pkgs; [
    neovim
    neovide
  ];
}