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
      lfs.enable = true;
      userName = "michaelgoldenn";
      userEmail = "Michael.Golden0278@gmail.com";
      ignores = [ "*~" "*.swp" ];
      aliases = {
        ci = "commit";
        ac = "!git add -A && git commit -m ";
        pp = "!git pull & git push";
      };
      extraConfig = {
        # init.defaultBranch = "master";
        # pull.rebase = "false";
      };
    };
    lazygit.enable = true;
  };

}
