# The main base of a unique tagging system. Each program has specific tags that can be set, 
# and will be enabled if any of them are enabled in the home directory
{ lib }:
{
  mkTaggedModule = { moduleName, tags, moduleConfig }:
    { config, ... }:
    {
      options.${moduleName} = {
        enable = lib.mkOption {
          type = lib.types.bool;
          default = null;
          description = "Explicitly enable/disable ${moduleName}. If null, determined by tags.";
        };

        tags = lib.mkOption {
          type = lib.types.listOf lib.types.str; # probably should switch this to an enum
          default = tags;
          description = "Tags that will automatically enable ${moduleName}";
        };
      };

      config =
        let
          anyTagEnabled = lib.any (tag: config.tags.${tag} or false) config.${moduleName}.tags;
          anyTagDisabled = lib.any
            (tag:
              (lib.hasAttr tag config.tags) && (config.tags.${tag} == false)
            )
            config.${moduleName}.tags;

          # Determine if module should be enabled:
          # 1. If explicitly set (true/false), use that
          # 2. If any tag is disabled, module is disabled
          # 3. If any tag is enabled, module is enabled
          # 4. Otherwise, disabled by default
          shouldEnable =
            if config.${moduleName}.enable != null
            then config.${moduleName}.enable
            else if anyTagDisabled
            then false
            else anyTagEnabled;
        in
        lib.mkIf shouldEnable moduleConfig;
    };
}
