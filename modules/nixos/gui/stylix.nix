{ flake, pkgs, ... }:
let
  inherit (flake) config inputs;
  inherit (inputs) self;
in
{
  imports = [
    flake.inputs.stylix.nixosModules.stylix
  ];
  home-manager.backupFileExtension = "backup"; # need this otherwise stylix runs into other configs and breaks HM
  stylix = {
    enable = true;
    image = pkgs.fetchurl {
      url = "https://images5.74932ac241946d4c3e5711ea2fe60f16.r2.cloudflarestorage.com/138/1381455.png?response-content-disposition=attachment%3B%20filename%3D%221381455.png%22&X-Amz-Content-Sha256=UNSIGNED-PAYLOAD&X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=25a1f3698f61250ae37fa2aae83c3913%2F20241120%2Fauto%2Fs3%2Faws4_request&X-Amz-Date=20241120T010028Z&X-Amz-SignedHeaders=host&X-Amz-Expires=60&X-Amz-Signature=ce3a2c3d3a4eec369ce894c9c54c949963e2c3929b013bfdf37bc8b842e7be7a";
      sha256 = "sha256-k2ABo3TOhj52vocn0ksNHuOba2F6uoT19WX+w1Rr6ls=";
    };
    # themes defined here: https://tinted-theming.github.io/base16-gallery/
    base16Scheme = "${pkgs.base16-schemes}/share/themes/catpucchin-frappe.yaml";
    /* Themes I've tried:
    catpucchin-frappe - comments are kinda hard to read
    
    */
    #image = ./wallpaper.png;
    polarity = "dark";
  };
}