## niri compositor, built from the personal fork (flake input `niri`). The login screen,
## keyring, polkit agent and other session pieces are in
## ./noctalia-session.nix; the user config (~/.config/niri/config.kdl) is written by
## /modules/home/gui/niri.nix.
{
  config,
  lib,
  pkgs,
  flake,
  ...
}:
{
  options.niri = {
    enable = lib.mkEnableOption "niri";
  };
  config = lib.mkIf config.niri.enable {
    programs.niri = {
      enable = true;
      # The test suite spins up whole compositor instances; skip it to keep rebuilds fast.
      package = flake.inputs.niri.packages.${pkgs.stdenv.hostPlatform.system}.niri.overrideAttrs {
        doCheck = false;
      };
    };

    # niri runs X11 apps through xwayland-satellite, spawned on demand when it's on PATH.
    environment.systemPackages = [ pkgs.xwayland-satellite ];
  };
}
