## Everyday desktop apps for the compositor-only session (niri). GNOME ships these as its
## core apps; a bare compositor ships nothing, so files would otherwise open in whatever
## happens to claim the type (images in Krita, PDFs in LibreOffice, ...).
## Clocks/weather/calendar are left out: noctalia covers them.
{
  config,
  lib,
  pkgs,
  ...
}:
let
  # { "app.desktop" = [ mime types ]; } -> { "mime/type" = "app.desktop"; }
  defaultsFor =
    apps:
    lib.foldlAttrs (
      acc: app: types:
      acc // lib.genAttrs types (_: app)
    ) { } apps;
in
{
  options.desktopApps.enable = lib.mkOption {
    type = lib.types.bool;
    default = config.waylandSession.enable;
    defaultText = lib.literalExpression "config.waylandSession.enable";
    description = "Whether to install GNOME-style everyday apps and make them the defaults";
  };

  config = lib.mkIf config.desktopApps.enable {
    home.packages = with pkgs; [
      loupe # image viewer
      papers # document (PDF) viewer
      vlc # video player
      decibels # audio player
      gnome-text-editor
      file-roller # archive manager, adds extract/compress to Nautilus' right-click menu
      gnome-calculator
      gnome-disk-utility # format/partition drives, write ISOs, SMART health
      baobab # disk usage analyzer
      snapshot # camera
      simple-scan # document scanner
      gnome-characters # emoji/symbol picker
      gnome-font-viewer
      pwvucontrol # per-app volume and audio device routing
      hyprpicker # screen color picker (works on any wlroots-style compositor, incl. niri)
      wl-clipboard # wl-copy, which hyprpicker -a uses to put the color on the clipboard
    ];

    # Launcher entry: type "color picker", click a pixel, hex lands on the clipboard.
    xdg.desktopEntries.color-picker = {
      name = "Color Picker";
      genericName = "Pick a color from the screen";
      comment = "Click any pixel to copy its hex color to the clipboard";
      icon = "color-select";
      categories = [ "Graphics" "Utility" ];
      exec = toString (
        pkgs.writeShellScript "color-picker" ''
          color=$(${lib.getExe pkgs.hyprpicker} --autocopy --format=hex) || exit 0
          [ -n "$color" ] && ${lib.getExe' pkgs.libnotify "notify-send"} -i color-select "Color copied" "$color"
        ''
      );
    };

    xdg.mimeApps.defaultApplications = defaultsFor {
      "org.gnome.Loupe.desktop" = [
        "image/png"
        "image/jpeg"
        "image/gif"
        "image/webp"
        "image/bmp"
        "image/tiff"
        "image/svg+xml"
        "image/avif"
        "image/heic"
        "image/jxl"
        "image/x-icon"
      ];
      "org.gnome.Papers.desktop" = [
        "application/pdf"
        "image/vnd.djvu"
        "application/x-cbz"
        "application/x-cbr"
      ];
      "vlc.desktop" = [
        "video/mp4"
        "video/x-matroska"
        "video/webm"
        "video/quicktime"
        "video/x-msvideo"
        "video/mpeg"
        "video/ogg"
        "video/x-flv"
      ];
      "org.gnome.Decibels.desktop" = [
        "audio/mpeg"
        "audio/flac"
        "audio/ogg"
        "audio/opus"
        "audio/wav"
        "audio/x-wav"
        "audio/mp4"
        "audio/aac"
      ];
      "org.gnome.TextEditor.desktop" = [
        "text/plain"
        "text/markdown"
        "text/x-log"
        "application/x-shellscript"
        "application/toml"
        "application/x-yaml"
      ];
      "org.gnome.FileRoller.desktop" = [
        "application/zip"
        "application/x-tar"
        "application/gzip"
        "application/x-compressed-tar"
        "application/x-xz-compressed-tar"
        "application/x-zstd-compressed-tar"
        "application/x-7z-compressed"
        "application/vnd.rar"
      ];
      "org.gnome.font-viewer.desktop" = [
        "font/ttf"
        "font/otf"
        "font/woff"
        "font/woff2"
      ];
    };
  };
}
