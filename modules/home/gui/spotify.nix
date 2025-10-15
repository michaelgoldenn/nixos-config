{
  pkgs,
  lib,
  config,
  flake,
  ...
}:
{
  imports = [
    flake.inputs.spicetify-nix.homeManagerModules.default
  ];

  options.spotify.enable = lib.mkEnableOption "spotify";

  config = lib.mkIf config.spotify.enable {
    programs.spicetify =
      let
        spicePkgs = flake.inputs.spicetify-nix.legacyPackages.${pkgs.system};
      in
      {
        enable = true;
        #extensions are defined here: https://github.com/Gerg-L/spicetify-nix/blob/master/docs/extensions.md
        enabledExtensions = with spicePkgs.extensions; [
          adblock
          hidePodcasts
          shuffle # shuffle+ (special characters are sanitized out of extension names)
          history
          showQueueDuration
          autoVolume
          songStats
          beautifulLyrics
          skipStats # shows stats on which songs you skip
          #oldSidebar
        ];
        enabledCustomApps = with spicePkgs.apps; [
          marketplace
        ];
        #Themes are defined here: https://github.com/Gerg-L/spicetify-nix/blob/master/docs/themes.md
        #Note: Not letting stylix handle spicetify stuff as I can't get custom themes with stylix atm.
        #theme = spicePkgs.themes.text;
        #colorScheme = "catppuccin-mocha";
        theme = spicePkgs.themes.catppuccin;
        colorScheme = "mocha";
      };
  };
}
