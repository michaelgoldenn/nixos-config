{ flake, pkgs, ... }:
let
  inherit (flake) inputs;
  inherit (inputs) nixpkgs-stable;
  
  # Get packages from nixpkgs-stable using the current system
  stablePkgs = import nixpkgs-stable { 
    system = pkgs.stdenv.hostPlatform.system;
    # Use the same configuration as the main nixpkgs
    config = pkgs.config;
  };
in
{
  # Nix packages to install to $HOME
  home.packages = with pkgs; [
    # Unix tools
    ripgrep # Better `grep`
    fd
    sd
    tree
    gnumake
    gnupg

    # Nix dev
    cachix
    nixd # Nix language server
    nix-info
    nixpkgs-fmt
    just
    alejandra
    nh

    # Dev
    tmate
    age
    rustup
    gcc
    rustlings
    #bacon

    # On ubuntu, we need this less for `man home-configuration.nix`'s pager to
    # work.
    less

    # cli doodads
    yt-dlp
    ffmpeg_7

    # Michael's custom stuff
    syncthing
    localsend
    unetbootin
    vlc
    qbittorrent
    #obsidian
    rare # "epic games launcher"
    stablePkgs.rustdesk  # Use rustdesk from stable
    prismlauncher
    #open-webui
    zoom-us
  ];

  nix.nixPath = [ "nixpkgs=${inputs.nixpkgs}" ];

  # Programs natively supported by home-manager.
  programs = {
    # Better `cat`
    bat.enable = true;
    # Type `<ctrl> + r` to fuzzy search your shell history
    fzf.enable = true;
    jq.enable = true;
  };
}