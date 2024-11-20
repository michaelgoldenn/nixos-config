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
    #base16Scheme = "${pkgs.base16-schemes}/share/themes/catpucchin-frappe.yaml";
    # for some reason it's breaking when I try to import like that - I'll import manually instead.
    base16Scheme = {
        base00 = "#303446"; # base
        base01 = "#292c3c"; # mantle
        base02 = "#414559"; # surface0
        base03 = "#51576d"; # surface1
        base04 = "#626880"; # surface2
        base05 = "#c6d0f5"; # text
        base06 = "#f2d5cf"; # rosewater
        base07 = "#babbf1"; # lavender
        base08 = "#e78284"; # red
        base09 = "#ef9f76"; # peach
        base0A = "#e5c890"; # yellow
        base0B = "#a6d189"; # green
        base0C = "#81c8be"; # teal
        base0D = "#8caaee"; # blue
        base0E = "#ca9ee6"; # mauve
        base0F = "#eebebe"; # flamingo
    };
    /* Themes I've tried:
    catpucchin-frappe - comments are kinda hard to read
    
    */
    #image = ./wallpaper.png;
    polarity = "dark";
  };
}