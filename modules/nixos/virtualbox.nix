{ flake, pkgs, ... }:
let
  inherit (flake) config inputs;
  inherit (inputs) self;
in
{
  virtualisation.virtualbox.host = {
    enable = true;
    enableExtensionPack = true;
  };
  #users.extraGroups.vboxusers.members = [ "michael" ];
}