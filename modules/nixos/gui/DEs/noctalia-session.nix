## System pieces shared by the compositor-only sessions (Hyprland, niri) that use the
## noctalia shell. GNOME and KDE ship all of this themselves; a bare compositor doesn't.
## noctalia itself is configured in home-manager (/modules/home/gui/noctalia) so stylix
## can theme it.
{
  config,
  lib,
  pkgs,
  ...
}:
{
  config = lib.mkIf (config.hyprland.enable || config.niri.enable) {
    # Noctalia's greetd greeter for the login screen. Without a display manager set here,
    # NixOS falls back to the default LightDM greeter.
    services.displayManager.noctalia-greeter = {
      enable = true;
      settings = {
        # The session must start graphical-session.target, or noctalia (and other session
        # services) won't start. For Hyprland that means the UWSM session; niri's own
        # session (niri-session) already does it.
        session.default = if config.niri.enable then "niri" else "Hyprland (uwsm-managed)";
        keyboard.layout = config.services.xserver.xkb.layout;
      };
      # Lets noctalia push its wallpaper and colors to the greeter (shell.greeter_sync)
      # without a password prompt every time the theme changes.
      passwordlessSyncUsers = lib.attrNames config.home-manager.users;
    };

    # noctalia only needs the freedesktop sound theme from the system side.
    xdg.sounds.enable = true;

    # Secret Service + polkit agent. Needed by the ProtonVPN app (stores its login in the
    # keyring, asks polkit to manage NetworkManager).
    services.gnome.gnome-keyring.enable = true;
    security.pam.services.greetd.enableGnomeKeyring = true;
    security.polkit.enable = true;
    # Despite the name it's a plain Qt polkit agent and works under any compositor.
    systemd.user.services.hyprpolkitagent = {
      description = "Polkit authentication agent";
      wantedBy = [ "graphical-session.target" ];
      partOf = [ "graphical-session.target" ];
      after = [ "graphical-session.target" ];
      serviceConfig = {
        ExecStart = "${pkgs.hyprpolkitagent}/libexec/hyprpolkitagent";
        Restart = "on-failure";
      };
    };

    # Virtual filesystem backends for Nautilus (network browsing, smb://, trash, MTP).
    services.gvfs.enable = true;

    # BlueZ daemon for noctalia's bluetooth widget.
    hardware.bluetooth = {
      enable = true;
      powerOnBoot = true;
    };

    xdg.portal = {
      enable = true;
      extraPortals = [ pkgs.xdg-desktop-portal-gtk ]; # file pickers and some GTK apps
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
