# Environment packages to be installed for all users
{ pkgs, ... }:
{
  specialisation = {
    gnome.configuration = {
      config.desktopEnvironment = "gnome";
    };
    cosmic.configuration = {
      config.desktopEnvironment = "cosmic";
    };
  };
  environment.systemPackages = with pkgs; [
    nixfmt-rfc-style
    eza
  ];
}
