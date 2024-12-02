{
  # this configures the shell if you hit `nix develop` while in the config file. Maybe it configures other shell too. idk
  perSystem = { pkgs, ... }: {
    devShells.default = pkgs.mkShell {
      name = "nixos-unified-template-shell";
      meta.description = "Shell environment for modifying this Nix configuration";
      shellHook = ''
        git config --local credential.helper '!f() { echo "username=PersonalAccessToken"; echo "password=$(cat /run/secrets/github/nixos)"; }; f'
      '';
      packages = with pkgs; [
        just
        nixd
        hello
      ];
    };
  };
}
