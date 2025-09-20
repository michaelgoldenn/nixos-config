## {{cookiecutter.description}}
{ config, lib, pkgs, ... }:
{
  options.{{cookiecutter.module_name}}.enable = lib.mkOption {
    type = lib.types.bool;
    default = true;
    description = "{{cookiecutter.description}}";
  };

  config = lib.mkIf config.{{cookiecutter.module_name}}.enable {
  home.packages = with pkgs;
  [
  ];
  programs = { };
};
}
