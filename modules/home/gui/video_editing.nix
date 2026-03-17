## Enables software used to edit videos and such
{
  config,
  lib,
  pkgs,
  ...
}:
{
  # imports = [
  #   ./davinci_resolve.nix
  # ];
  options.video_editing.enable = lib.mkEnableOption "video_editing";

  config = lib.mkIf config.video_editing.enable {
    nixpkgs.config.cudaSupport = true;
    home.packages = with pkgs; [
      (obs-studio.override { cudaSupport = true; })
      # davinci-resolve
      audacity
      vlc
      ardour # daw
    ];
  };
}
