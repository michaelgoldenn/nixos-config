# Whether or not we should allow the user's pc to suspend.
{
  config,
  lib,
  ...
}:
{
  options.suspend = lib.mkOption {
    type = lib.types.bool;
    default = true;
    description = "Allows computer to suspend (deep sleep) after a certain period of time";
  };

  config = lib.mkIf (!config.suspend) {
    # Disable systemd suspend/sleep targets
    systemd.targets.sleep.enable = false;
    systemd.targets.suspend.enable = false;
    systemd.targets.hibernate.enable = false;
    systemd.targets.hybrid-sleep.enable = false;
  };
}
