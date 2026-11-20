## Entirely AI generated.
##
## Live theme switching.
##
## Every entry in the ./themes.nix registry other than the active one is turned into a
## home-manager specialisation. A specialisation is a complete, pre-built activation
## script sitting in the current generation, so switching to one is a file copy and a
## `dconf load` rather than a nix evaluation — roughly a second, no sudo, no rebuild.
##
##   theme            # fuzzy picker in the terminal
##   theme pick       # graphical picker (wofi on wayland, rofi on x11)
##   theme set NAME   # switch directly
##   theme next       # cycle to the next theme
##   theme list / theme current
##   theme restore    # re-apply the last pick, e.g. after a rebuild
##
## Caveat worth knowing: activating a specialisation makes it the current generation, and
## that generation has no specialisations of its own (home-manager blanks them to avoid
## infinite recursion). So the switcher can't just look at the current generation — the
## activation hook below records a symlink to the *base* generation, the one that does
## carry the specialisation directory, and every switch is dispatched from there.
{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.theme;

  # Only the data the script needs at runtime. Deliberately free of any reference to the
  # specialisations themselves: the script lives inside every specialisation's package
  # set, so pointing it at their store paths would be an infinite recursion.
  themesJson = pkgs.writeText "themes.json" (
    builtins.toJSON (
      lib.mapAttrs (_: t: {
        inherit (t) polarity swatch;
        image = toString t.image;
      }) cfg.themes
    )
  );

  stateDirExpr = ''"''${XDG_STATE_HOME:-$HOME/.local/state}/theme"'';

  theme-switch = pkgs.writeShellApplication {
    name = "theme";
    runtimeInputs = with pkgs; [
      jq
      fzf
      chafa
      libnotify
      wofi
      rofi
    ];
    text = ''
      themesFile=${themesJson}
      stateDir=${stateDirExpr}
      self=''${BASH_SOURCE[0]}

      die() {
        echo "theme: $*" >&2
        exit 1
      }

      themeNames() { jq -r 'keys[]' "$themesFile"; }

      knownTheme() { themeNames | grep -qxF "$1"; }

      # The generation that actually carries the specialisation directory. Recorded by the
      # home-manager activation hook; see the note at the top of this file.
      baseGeneration() {
        local link="$stateDir/base-generation"
        [ -e "$link" ] || die "no base generation recorded yet, rebuild first (\`just run\`)"
        readlink -f "$link"
      }

      currentTheme() { cat "$stateDir/current" 2>/dev/null || echo ""; }
      baseTheme() { cat "$stateDir/base-theme" 2>/dev/null || echo ""; }

      # Draws the theme's swatch as a row of truecolor blocks.
      swatchBar() {
        jq -r --arg n "$1" '.[$n].swatch[]?' "$themesFile" | while read -r hex; do
          printf '\033[48;2;%d;%d;%dm   \033[0m' \
            "$((16#''${hex:1:2}))" "$((16#''${hex:3:2}))" "$((16#''${hex:5:2}))"
        done
        echo
      }

      preview() {
        local name=$1 polarity image
        polarity=$(jq -r --arg n "$name" '.[$n].polarity' "$themesFile")
        image=$(jq -r --arg n "$name" '.[$n].image' "$themesFile")
        printf '\033[1m%s\033[0m (%s)\n\n' "$name" "$polarity"
        swatchBar "$name"
        echo
        # chafa renders the wallpaper as terminal graphics; harmless if the terminal
        # can't do better than ASCII.
        chafa --size="''${FZF_PREVIEW_COLUMNS:-60}x''${FZF_PREVIEW_LINES:-20}" "$image" 2>/dev/null || true
      }

      applyTheme() {
        local name=$1 base activate out
        knownTheme "$name" || die "unknown theme '$name'. Known: $(themeNames | tr '\n' ' ')"

        base=$(baseGeneration)
        if [ "$name" = "$(baseTheme)" ]; then
          activate="$base/activate"
        else
          activate="$base/specialisation/$name/activate"
        fi
        [ -x "$activate" ] || die "no activation script for '$name' at $activate"

        # Remember the pick separately from $stateDir/current: a rebuild rewrites
        # `current` with whatever theme.name is in the flake, but `desired` is ours.
        mkdir -p "$stateDir"
        printf '%s\n' "$name" >"$stateDir/desired"

        if ! out=$("$activate" 2>&1); then
          printf '%s\n' "$out" >&2
          die "activation of '$name' failed"
        fi

        notify-send -a theme -i "$(jq -r --arg n "$name" '.[$n].image' "$themesFile")" \
          "Theme" "$name" 2>/dev/null || true
        echo "theme: now using $name"
      }

      pickGraphical() {
        local -a menu
        if [ -n "''${WAYLAND_DISPLAY:-}" ] && command -v wofi >/dev/null; then
          menu=(wofi --dmenu --prompt Theme)
        elif command -v rofi >/dev/null; then
          menu=(rofi -dmenu -p Theme)
        else
          die "no graphical picker available (wanted wofi or rofi)"
        fi
        themeNames | "''${menu[@]}"
      }

      case "''${1-}" in
      list) themeNames ;;
      current) currentTheme ;;
      set)
        [ $# -eq 2 ] || die "usage: theme set NAME"
        applyTheme "$2"
        ;;
      next)
        mapfile -t names < <(themeNames)
        cur=$(currentTheme)
        idx=0
        for i in "''${!names[@]}"; do
          if [ "''${names[$i]}" = "$cur" ]; then idx=$i; fi
        done
        applyTheme "''${names[$(((idx + 1) % ''${#names[@]}))]}"
        ;;
      restore)
        want=$(cat "$stateDir/desired" 2>/dev/null || echo "")
        [ -n "$want" ] || die "nothing to restore, no theme picked yet"
        if [ "$want" != "$(currentTheme)" ]; then applyTheme "$want"; fi
        ;;
      pick)
        choice=$(pickGraphical) || choice=""
        if [ -n "$choice" ]; then applyTheme "$choice"; fi
        ;;
      # Called back by fzf to render the preview pane.
      __preview)
        preview "$2"
        ;;
      "")
        if [ -t 0 ] && [ -t 1 ]; then
          choice=$(themeNames | fzf --exit-0 \
            --prompt 'theme> ' \
            --height 60% --reverse \
            --preview "$self __preview {}" \
            --preview-window 'right:60%') || choice=""
        else
          choice=$(pickGraphical) || choice=""
        fi
        if [ -n "''${choice:-}" ]; then applyTheme "$choice"; fi
        ;;
      -h | --help | help)
        cat <<'USAGE'
      theme              fuzzy-pick a theme in the terminal
      theme pick         pick a theme from a graphical menu
      theme set NAME     switch to NAME
      theme next         cycle to the next theme
      theme list         list available themes
      theme current      print the active theme
      theme restore      re-apply the last pick (e.g. after a rebuild)
      USAGE
        ;;
      *) die "unknown command '$1', try \`theme --help\`" ;;
      esac
    '';
  };
in
{
  config = {
    # One specialisation per theme other than the current one. `specialisation` blanks
    # itself inside each nested configuration, so this does not recurse.
    specialisation = lib.mapAttrs (name: _: {
      configuration.theme.name = lib.mkForce name;
    }) (lib.filterAttrs (name: _: name != cfg.name) cfg.themes);

    home.packages = [ theme-switch ];

    # Runs on every activation, base and specialisation alike, so `theme current` always
    # reflects reality. The base-generation pointer is only written by generations that
    # carry specialisations, i.e. the base one.
    home.activation.themeState = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      stateDir=${stateDirExpr}
      if [[ ! -v DRY_RUN ]]; then
        mkdir -p "$stateDir"
        printf '%s\n' ${lib.escapeShellArg cfg.name} >"$stateDir/current"
        if [[ -d "$newGenPath/specialisation" ]]; then
          ln -sfn "$newGenPath" "$stateDir/base-generation"
          printf '%s\n' ${lib.escapeShellArg cfg.name} >"$stateDir/base-theme"
        fi
      fi
    '';
  };
}
