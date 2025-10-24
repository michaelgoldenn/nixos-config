{ config, ... }:
{
  home.shellAliases = {
    g = "git";
    lg = "lazygit";
  };

  # https://nixos.asia/en/git
  programs = {
    git = {
      enable = true;
      settings.user = {
        name = config.me.fullname;
        email = config.me.email;
        ignores = [
          "*~"
          "*.swp"
        ];
        aliases = {
          ci = "commit";
        };
        init.defaultBranch = "main";
      };
    };
    lazygit.enable = true;
  };

}
