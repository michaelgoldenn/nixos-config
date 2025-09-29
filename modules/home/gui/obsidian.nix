## Enables Obsidian.md
{
  config,
  lib,
  pkgs,
  ...
}:
{
  options.obsidian.enable = lib.mkOption {
    type = lib.types.bool;
    default = true;
    description = "Enables Obsidian.md";
  };

  config = lib.mkIf config.obsidian.enable {
    home.packages = [ pkgs.obsidian ];
    
    # Don't use home-manager for now, it forces you to declaritively define everything (https://github.com/nix-community/home-manager/issues/7906)
    # programs.obsidian = {
    #   enable = true;
    #   vaults = {
    #     main-vault = {
    #       enable = true;
    #       target = "Documents/obsidian-vault";
    #     };
    #   };
    # };
    # stylix.targets.obsidian.vaultNames = [ "main-vault" ]; # add main vault to stylix
  };
}
