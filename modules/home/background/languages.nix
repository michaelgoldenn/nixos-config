{lib, pkgs, ...}: {
  home.packages = with pkgs; [
    # c
    (lib.hiPrio clang)
    clang-tools
    (lib.lowPrio gcc) # set gcc to low priority to avoid conflicts with clang
  ];
}