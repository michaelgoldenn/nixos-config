## Sets the default shell based on what's set in home-manager.
{ config, pkgs, ... }:
{
  # Assumes the value used in home-manager is a valid package in nixpkgs.
  # If that isn't the case, it'll break adn you'll probably have to use a bunch of `if`s to get the package
  users.users.michael = {
    shell = pkgs.${config.home-manager.users.michael.shell.default};
  };
}


