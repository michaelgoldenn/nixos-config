{ pkgs, ... }:
{
  programs.foot = {
    enable = false;
    #enableNushellIntegration = true;
    settings = {
      main = {
        shell = "${pkgs.bash}/bin/bash --login -c 'nu --login --interactive'";
      };
    };
  };

}