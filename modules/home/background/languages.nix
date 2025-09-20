{lib, pkgs, ...}: {
  home.packages = with pkgs; [
    # c
    clang
    clang-tools
  ];
}