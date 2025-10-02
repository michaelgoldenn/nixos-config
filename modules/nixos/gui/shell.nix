## Sets the default shell based on what's set in home-manager.
{ lib, config, pkgs, ... }:
{
  # Since we can't set default shell in home-manager, manually set each user's shell to the default in home-manager
  # It'll require a restart when you change the default, but it should work fine other than that
  users.users = lib.mapAttrs (username: hmConfig: {
    shell = pkgs.${hmConfig.shell.default};
  }) config.home-manager.users;

}
