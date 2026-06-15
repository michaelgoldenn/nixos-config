{
  flake,
  ...
}:
{
  # imports = [
  #   flake.inputs.direnv-instant.homeModules.direnv-instant
  # ];
  # programs.direnv-instant.enable = true;
  # https://nixos.asia/en/direnv
  programs.direnv = {
    enable = true;
    nix-direnv = {
      enable = true;
    };
    config.global = {
      # Make direnv messages less verbose
      hide_env_diff = true;
    };
  };
}
