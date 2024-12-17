{ pkgs, ... }:
{
  programs.foot = {
    enable = true;
    #enableNushellIntegration = true;
    settings = {
      main = {
        shell = "${pkgs.bash}/bin/bash --login -c 'nu --login --interactive'";
      };
    };
  };

}