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
    programs.obsidian = {
      enable = true;
    };
  };
}
