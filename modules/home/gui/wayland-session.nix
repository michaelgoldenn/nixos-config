## User services shared by the compositor-only sessions (Hyprland, niri). GNOME and KDE
## cover these themselves.
{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.waylandSession;
  # Plain playerctl just picks the first MPRIS player it finds (often a paused browser
  # tab), so the media keys go through this instead. It targets whichever player last
  # changed between playing and paused, as recorded by the media-last-player service.
  media-last-player-file = "\${XDG_RUNTIME_DIR:-/tmp}/media-last-player";
  media-control = pkgs.writeShellApplication {
    name = "media-control";
    runtimeInputs = [ pkgs.playerctl ];
    text = ''
      player=$(cat "${media-last-player-file}" 2>/dev/null || true)
      if [ -n "$player" ] && playerctl --player="$player" status >/dev/null 2>&1; then
        exec playerctl --player="$player" "$@"
      fi
      exec playerctl "$@"
    '';
  };
in
{
  options.waylandSession = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = config.hyprland.enable || config.niri.enable;
      defaultText = lib.literalExpression "config.hyprland.enable || config.niri.enable";
      description = "Whether a compositor-only session (with the noctalia shell) is in use";
    };
    mediaControl = lib.mkOption {
      type = lib.types.package;
      readOnly = true;
      default = media-control;
      description = "playerctl wrapper that targets the most recently played/paused player";
    };
  };

  config = lib.mkIf cfg.enable {
    # Records the player that most recently started or stopped playing, for media-control.
    # A player only counts when its status flips; one that shows up already paused (like
    # a newly opened browser tab) is ignored.
    systemd.user.services.media-last-player = {
      Unit = {
        Description = "Track the most recently played/paused media player";
        PartOf = [ "graphical-session.target" ];
        After = [ "graphical-session.target" ];
      };
      Service = {
        ExecStart = lib.getExe (
          pkgs.writeShellApplication {
            name = "media-last-player";
            runtimeInputs = [ pkgs.playerctl ];
            text = ''
              declare -A seen=()
              playerctl --all-players --follow status --format '{{playerInstance}} {{status}}' |
                while read -r player status; do
                  [ -n "$player" ] && [ -n "''${status:-}" ] || continue
                  prev=''${seen[$player]:-}
                  seen[$player]=$status
                  [ "$prev" != "$status" ] || continue
                  if [ -n "$prev" ] || [ "$status" = Playing ]; then
                    echo "$player" >"${media-last-player-file}"
                  fi
                done
            '';
          }
        );
        Restart = "always";
        RestartSec = 2;
      };
      Install.WantedBy = [ "graphical-session.target" ];
    };

    # Holds an idle inhibitor while anything is playing audio through PipeWire, so music
    # or videos keep the screen on and stop auto-suspend (GNOME used caffeine for this).
    systemd.user.services.wayland-pipewire-idle-inhibit = {
      Unit = {
        Description = "Inhibit idle while audio is playing";
        PartOf = [ "graphical-session.target" ];
        After = [
          "graphical-session.target"
          "pipewire.service"
        ];
      };
      Service = {
        ExecStart = lib.getExe pkgs.wayland-pipewire-idle-inhibit;
        Restart = "on-failure";
        RestartSec = 5;
      };
      Install.WantedBy = [ "graphical-session.target" ];
    };
  };
}
