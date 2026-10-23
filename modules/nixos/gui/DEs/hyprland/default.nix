{
  config,
  lib,
  pkgs,
  ...
}:
{
  options.hyprland = {
    enable = lib.mkEnableOption "hyprland";
  };
  config = lib.mkIf config.hyprland.enable {
    programs.hyprland = {
      enable = true;
      withUWSM = true;
      xwayland.enable = true;
    };

    # Noctalia's greetd greeter for the login screen. Without a display manager set here,
    # NixOS falls back to the default LightDM greeter.
    services.displayManager.noctalia-greeter = {
      enable = true;
      settings = {
        # The plain "Hyprland" session never starts graphical-session.target, so
        # noctalia (and other session services) wouldn't start. Default to UWSM.
        session.default = "Hyprland (uwsm-managed)";
        keyboard.layout = config.services.xserver.xkb.layout;
      };
      # Lets noctalia push its wallpaper and colors to the greeter (shell.greeter_sync)
      # without a password prompt every time the theme changes.
      passwordlessSyncUsers = lib.attrNames config.home-manager.users;
    };

    # noctalia itself is configured in home-manager (/modules/home/gui/hyprland.nix) so stylix
    # can theme it. It only needs the freedesktop sound theme from the system side.
    xdg.sounds.enable = true;

    # Secret Service + polkit agent: GNOME provides these, Hyprland doesn't. Needed by the
    # ProtonVPN app (stores its login in the keyring, asks polkit to manage NetworkManager).
    services.gnome.gnome-keyring.enable = true;
    security.pam.services.greetd.enableGnomeKeyring = true;
    security.polkit.enable = true;
    systemd.user.services.hyprpolkitagent = {
      description = "Hyprland polkit authentication agent";
      wantedBy = [ "graphical-session.target" ];
      partOf = [ "graphical-session.target" ];
      after = [ "graphical-session.target" ];
      serviceConfig = {
        ExecStart = "${pkgs.hyprpolkitagent}/libexec/hyprpolkitagent";
        Restart = "on-failure";
      };
    };

    # Virtual filesystem backends for Nautilus (network browsing, smb://, trash, MTP).
    # GNOME enables this implicitly; Hyprland doesn't.
    services.gvfs.enable = true;

    # BlueZ daemon for noctalia's bluetooth widget. GNOME/KDE enable this implicitly;
    # Hyprland doesn't.
    hardware.bluetooth = {
      enable = true;
      powerOnBoot = true;
    };

    xdg.portal = {
      enable = true;
      extraPortals = with pkgs; [
        xdg-desktop-portal-hyprland
        xdg-desktop-portal-gtk # needed for file pickers and some GTK apps
      ];
    };

    environment.systemPackages = with pkgs; [
      # Screenshot / screen capture
      grim # screenshot tool
      slurp # region selector (used with grim)
      satty # annotation tool
      swappy # snapshot editor
      mpvpaper # video/mpv wallpaper
      eww # widget system
      quickshell # alternative shell/widget layer
      playerctl # media player control (play/pause/next from keybinds)
      matugen # material you color generation
      wmctrl # window control scripting
      nautilus # gnome's file manager
      nautilus-open-any-terminal
    ];
  };
}
