{
  description = "My custom flake templates";
  outputs = { self, ... }: {
    templates = {
      hm-module = {
        path = ./hm-module.nix;
        description = "My standard home-manager module";
      };
    };
  };
}
