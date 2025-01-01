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
     enabledExtensions = with spicePkgs.extensions; [
       adblock
       hidePodcasts
       shuffle # shuffle+ (special characters are sanitized out of extension names)
       history
       showQueueDuration
       autoVolume
       songStats
       beautifulLyrics
       oldSidebar
     ];
     #Themes are defined here: https://github.com/Gerg-L/spicetify-nix/blob/master/docs/THEMES.md
     #Note: Not letting stylix handle spicetify stuff as I can't get custom themes with stylix atm.
     #theme = spicePkgs.themes.text;
     #colorScheme = "catppuccin-mocha";
     theme = spicePkgs.themes.catppuccin;
     colorScheme = "mocha";
   };
}