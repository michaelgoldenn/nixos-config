{ flake, pkgs, ... }:
let
  inherit (flake) config inputs;
  inherit (inputs) self;
in
{
  # Nix packages to install to $HOME
  #
  # Search for packages here: https://search.nixos.org/packages
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
    rustdesk
    prismlauncher
    open-webui
    
    #making games
    godot_4
    blender
  ];

  systemd.user.services.open-webui = {
    Unit = {
      Description = "Open WebUI Service";
    };
    Service = {
      Environment = "OPEN_WEBUI_DATA_PATH=%h/.local/share/open-webui";
      ExecStartPre = "${pkgs.coreutils}/bin/mkdir -p %h/.local/share/open-webui";
      ExecStart = "${pkgs.open-webui}/bin/open-webui serve";
    };
  };

  nix.nixPath = [ "nixpkgs=${inputs.nixpkgs}" ];

  # Programs natively supported by home-manager.
  # They can be configured in `programs.*` instead of using home.packages.
  programs = {
    # Better `cat`
    bat.enable = true;
    # Type `<ctrl> + r` to fuzzy search your shell history
    fzf.enable = true;
    jq.enable = true;
    # Install btop https://github.com/aristocratos/btop
    btop.enable = true;
  };
}
