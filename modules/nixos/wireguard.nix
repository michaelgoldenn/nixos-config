{
  config,
  pkgs,
  lib,
  ...
}: 
{
  networking.wireguard = {
    enable = true;
  };
}