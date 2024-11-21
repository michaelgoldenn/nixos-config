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
      url = "https://images-wixmp-ed30a86b8c4ca887773594c2.wixmp.com/f/b3be1dae-3caa-4d45-be6c-3de586ba95e2/ddgdrgz-d17ad9e8-ea29-43e0-8d78-3f2cf417904e.jpg/v1/fill/w_1192,h_670,q_70,strp/trekking_by_bisbiswas_ddgdrgz-pre.jpg?token=eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJzdWIiOiJ1cm46YXBwOjdlMGQxODg5ODIyNjQzNzNhNWYwZDQxNWVhMGQyNmUwIiwiaXNzIjoidXJuOmFwcDo3ZTBkMTg4OTgyMjY0MzczYTVmMGQ0MTVlYTBkMjZlMCIsIm9iaiI6W1t7ImhlaWdodCI6Ijw9OTAwIiwicGF0aCI6IlwvZlwvYjNiZTFkYWUtM2NhYS00ZDQ1LWJlNmMtM2RlNTg2YmE5NWUyXC9kZGdkcmd6LWQxN2FkOWU4LWVhMjktNDNlMC04ZDc4LTNmMmNmNDE3OTA0ZS5qcGciLCJ3aWR0aCI6Ijw9MTYwMCJ9XV0sImF1ZCI6WyJ1cm46c2VydmljZTppbWFnZS5vcGVyYXRpb25zIl19.3X7CC676xnkcaCTA7Ir3lXEF2DVXC0MO38c9mXsk0_c";
      sha256 = "sha256-wy8zgts9tS2at1S8YhodXZ5IR/vpRbpWBJaSv/24nJI=";
    };
    #image = ../../../bash/videos/random_frame.jpg;
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
    polarity = "dark";
  };
}