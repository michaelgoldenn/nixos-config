{
  pkgs,
  ...
}: {
  home.packages = with pkgs; [
    ty
    ruff
    (python3.withPackages (ps: with ps; [
      jedi-language-server
      python-lsp-server  # This provides 'pylsp'
    ]))
  ];
}