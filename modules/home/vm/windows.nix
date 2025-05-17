{ pkgs, config, ... }:
let
  runWindows = pkgs.writeShellScriptBin "run-windows" ''
    exec quickemu --vm "${config.home.homeDirectory}/system/vm/windows-11.conf" --display spice
  '';
in
{
  home.packages = with pkgs; [
    quickemu
    spice-gtk
    runWindows           # add the wrapper to $PATH
  ];

  xdg.desktopEntries.windows = {
    name        = "Windows 11";
    genericName = "Windows VM";
    exec        = "run-windows";
    icon        = "distributor-logo-windows";
    terminal    = false;   # set to true if you want to see stdout/stderr
  };
}
