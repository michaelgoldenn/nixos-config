# Environment packages to be installed for all users
{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    nixfmt-rfc-style
    eza
  ];
}
