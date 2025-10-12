# Environment packages to be installed for all users
{
  pkgs,
  lib,
  config,
  ...
}:
{
  environment.systemPackages = with pkgs; [
    nixfmt-rfc-style
    eza
  ];
}
