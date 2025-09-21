## The stylix module gives more options so I'm defining it here as well as in home-manager.
## That might be a bad idea since it won't be synced with the main color scheme but if it causes any issues I can
##  just get rid of this module.
{ flake, pkgs, ... }:
{
  imports = [
    flake.inputs.stylix.nixosModules.stylix
  ];
  stylix = {
    enable = true;
    # need to enter color scheme for it to work properly, will get overwritten by home-manager stylix config
    base16Scheme = "${pkgs.base16-schemes}/share/themes/catppuccin-mocha.yaml";
  };
}
