## noctalia (v5) shell config. Configured on the home-manager side rather than NixOS so the
## stylix noctalia target can theme it, and `theme set` swaps its palette live.
## The settings themselves live in ./config.toml (upstream defaults + local edits); only
## values that depend on the theme / this machine are overridden here.
{
  config,
  lib,
  ...
}:
{
  config = lib.mkIf config.hyprland.enable (
    let
      style = config.theme.selected.style;
      slot = name: config.lib.stylix.colors.${name};
    in
    {
      programs.noctalia = {
        enable = true;
        # Started by graphical-session.target, which only the UWSM session reaches.
        systemd.enable = true;
        # Anything changed in noctalia's settings window lands in
        # ~/.local/state/noctalia/settings.toml and wins over this (including stylix's colors).
        # The TOML is set at default priority so stylix's own values (colors, dock opacity)
        # still win where they overlap.
        settings = lib.mkMerge [
          (lib.mapAttrsRecursive (_: lib.mkDefault) (builtins.fromTOML (builtins.readFile ./config.toml)))
          {
            shell = {
              corner_radius_scale = style.cornerScale;
              avatar_path = "${config.home.homeDirectory}/.face";
            };
            wallpaper.directory = "${config.home.homeDirectory}/Pictures/Wallpapers";
            # noctalia has no bar background key (it always uses the palette's surface), so a
            # coloured bar is an inside outline as thick as the bar itself, i.e. a solid fill.
            bar.main = lib.optionalAttrs (style.barColor != null) {
              thickness = 36;
              radius = 0;
              border = "#${slot style.barColor}";
              border_width = 36;
              color = "#ffffff";
              compositor_blur = false;
            };
          }
        ];
      };
    }
  );
}
