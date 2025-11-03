{
  config,
  lib,
  flake,
  ...
}:
{
  options = {
    grub.enable = lib.mkEnableOption "grub";
  };

  imports = [ flake.inputs.minegrub-theme.nixosModules.default ];

  config = lib.mkIf config.grub.enable {
    boot.loader.grub = lib.mkForce {
      enable = true;
      device = "nodev";
      efiSupport = true;
      minegrub-theme = {
        enable = true;
        splash = "100% Flakes!";
        background = "background_options/1.8  - [Classic Minecraft].png";
        boot-options-count = 4;
      };
    };
  };
}
