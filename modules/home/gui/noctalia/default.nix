## noctalia (v5) shell config. Configured on the home-manager side rather than NixOS so the
## stylix noctalia target can theme it, and `theme set` swaps its palette live.
## The settings themselves live in ./config.toml (upstream defaults + local edits); only
## values that depend on the theme / this machine are overridden here.
{
  config,
  lib,
  pkgs,
  ...
}:
{
  options.noctalia.powerProfileLabels = lib.mkOption {
    type = lib.types.attrsOf lib.types.str;
    default = { };
    example = {
      power-saver = "Silent";
    };
    description = ''
      English labels to show for power profiles (power-saver, balanced, performance) instead
      of noctalia's defaults. noctalia only knows those three profile names, so this only
      renames them.
    '';
  };

  config = lib.mkIf config.waylandSession.enable (
    let
      style = config.theme.selected.style;
      slot = name: config.lib.stylix.colors.${name};
      labels = config.noctalia.powerProfileLabels;

      # noctalia reads its assets (translations included) from next to its binary unless
      # NOCTALIA_ASSETS_DIR points elsewhere, so relabelling means a patched copy of the
      # assets and a wrapper setting that variable, rather than rebuilding noctalia.
      relabelled =
        let
          base = pkgs.noctalia;
          assets =
            pkgs.runCommand "noctalia-assets-relabelled"
              {
                nativeBuildInputs = [ pkgs.jq ];
                labels = builtins.toJSON labels;
              }
              ''
                cp -rs ${base}/share/noctalia/assets $out
                chmod u+w $out/translations
                rm $out/translations/en.json
                jq --argjson labels "$labels" '.power.profiles += $labels' \
                  ${base}/share/noctalia/assets/translations/en.json > $out/translations/en.json
              '';
        in
        pkgs.symlinkJoin {
          name = "noctalia-${base.version}";
          paths = [ base ];
          nativeBuildInputs = [ pkgs.makeWrapper ];
          postBuild = ''
            wrapProgram $out/bin/noctalia --set NOCTALIA_ASSETS_DIR ${assets}
          '';
          inherit (base) version;
          meta = base.meta // {
            mainProgram = "noctalia";
          };
        };
    in
    {
      programs.noctalia = {
        enable = true;
        package = lib.mkIf (labels != { }) relabelled;
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
              screenshot.directory = "${config.home.homeDirectory}/Pictures/Screenshots";
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
