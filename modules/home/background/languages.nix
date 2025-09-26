{lib, pkgs, ...}: {
  home.packages = with pkgs; [
    # c
    # set gcc to low priority to avoid conflicts with clang
    (lib.hiPrio clang)
    clang-tools
    (lib.lowPrio gcc)
    lldb
  ];
}