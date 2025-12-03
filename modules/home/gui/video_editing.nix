## Enables software used to edit videos and such
{
  config,
  lib,
  pkgs,
  ...
}:
{
  options.video_editing.enable = lib.mkEnableOption "video_editing";

  config = lib.mkIf config.video_editing.enable {
    home.packages = with pkgs; [
      obs-studio
      davinci-resolve
      audacity
      vlc
      ardour # daw
    ];
  };
}
