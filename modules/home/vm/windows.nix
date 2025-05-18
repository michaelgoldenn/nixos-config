{
  pkgs,
  config,
  ...
}: let
  runWindows = pkgs.writeShellScriptBin "run-windows" ''
    exec quickemu --vm "${config.home.homeDirectory}/projects/VMs/windows-11/windows-11.conf" --ignore-msrs
  '';
in {
  home.packages = with pkgs; [quickemu spice-gtk runWindows];

  xdg.desktopEntries.windows = {
    name = "Windows 11";
    genericName = "Windows VM";
    exec = "run-windows";
    icon = "distributor-logo-windows";
    terminal = false;
  };
}
