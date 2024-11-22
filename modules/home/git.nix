{ ... }:
{
  home.shellAliases = {
    g = "git";
    lg = "lazygit";
  };

  # https://nixos.asia/en/git
  programs = {
    git = {
      enable = true;
      userName = "michaelgoldenn";
      userEmail = "Michael.Golden0278@gmail.com";
      ignores = [ "*~" "*.swp" ];
      aliases = {
        ci = "commit";
      };
      extraConfig = {
        # init.defaultBranch = "master";
        # pull.rebase = "false";
      };
    };
    lazygit.enable = true;
  };

}
