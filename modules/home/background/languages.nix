{ lib, pkgs, ... }: {
  home.packages = with pkgs; [
    # nix
    nixd
    nil
    # c
    # set gcc to low priority to avoid conflicts with clang
    (lib.hiPrio clang)
    clang-tools
    (lib.lowPrio gcc)
    lldb

    # rust
    rust-analyzer
    bacon # not needed for language functionality, but nice for dev

    # python
    ty
    ruff
    (python3.withPackages (ps: with ps; [
      jedi-language-server
      python-lsp-server # This provides 'pylsp'
    ]))

    # configuration languages
    vscode-json-languageserver # json
    taplo # toml
  ];
}
