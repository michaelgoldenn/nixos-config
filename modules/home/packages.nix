{ pkgs, ... }:
{
  # Nix packages to install to $HOME
  #
  # Search for packages here: https://search.nixos.org/packages
  home.packages = with pkgs; [
    omnix

    # Unix tools
    fd
    sd
    tree
    gnumake

    # Nix dev (nix formatter to use is defined in toplevel.nix (for some reason))
    cachix
    nix-info
    nixfmt-rfc-style
    nixfmt-tree

    # On ubuntu, we need this less for `man home-configuration.nix`'s pager to
    # work.
    less
  ];
}
