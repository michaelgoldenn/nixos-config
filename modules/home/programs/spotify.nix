{ flake, pkgs, ... }:
let
  inherit (flake) config inputs;
  inherit (inputs) self;
in
{
  imports = [
    # For home-manager
    inputs.spicetify-nix.homeManagerModules.default
  ];
  programs.spicetify =
   let
     spicePkgs = inputs.spicetify-nix.legacyPackages.${pkgs.system};
   in
   {
     enable = true;
     #extensions are defined here: https://github.com/Gerg-L/spicetify-nix/blob/master/docs/EXTENSIONS.md
/*      enabledExtensions = with spicePkgs.extensions; [
       adblock
       hidePodcasts
       #shuffle # shuffle+ (special characters are sanitized out of extension names)
       history
       showQueueDuration
       autoVolume
       songStats
       beautifulLyrics
     ]; */
     #Let stylix handle the theming
     #Themes are defined here: https://github.com/Gerg-L/spicetify-nix/blob/master/docs/THEMES.md
     #theme = spicePkgs.themes.text;
     #colorScheme = "mocha"; #not working rn for some reason, fix later (maybe with stylix?)
   };
}
/* {} */