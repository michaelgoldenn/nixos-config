{ flake, lib, pkgs, config, ... }:
let
  inherit (flake) inputs;
  inherit (inputs) self;
in
{
  imports = [
    flake.inputs.stylix.nixosModules.stylix
  ];
  
  home-manager.backupFileExtension = "backup";
  
  stylix = {
    enable = true;
    image = pkgs.fetchurl {
      url = "https://raw.githubusercontent.com/orangci/walls/refs/heads/main/isekai.jpg";
      sha256 = "sha256-PoOg8v5+Zkjf8hz7GvH8paCC29BcyHePgeXMghv9Zpo=";
    };
    # The base16Scheme will be inherited from home-manager
    polarity = "dark";
    cursor = {
      package = pkgs.bibata-cursors;
      name = "Bibata-Modern-Classic";
      size = 20;
    };
  };
}