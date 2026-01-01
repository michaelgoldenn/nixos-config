{
  config,
  lib,
  pkgs,
  ...
}:
{
  options.vr.enable = lib.mkEnableOption "vr";

  config = lib.mkIf config.vr.enable {
    environment.defaultPackages = [
      pkgs.bs-manager
    ];

    services.wivrn = {
      enable = true;
      openFirewall = true;
      defaultRuntime = true;
      autoStart = true;

      # Define the package using the specific PR
      package =
        let
          # 1. Fetch the specific version of nixpkgs
          prPkgs =
            import
              (builtins.fetchTarball {
                # URL to the archive of the specific commit
                url = "https://github.com/NixOS/nixpkgs/archive/7d24905cd37a24ad9e811e068c0ca0e9ea23edbb.tar.gz";
                sha256 = "1vbq1h0lxwkij5a9h447rcy3jl0z2jw8kh1dgfbwp99bksky9sdg";
              })
              {
                # Ensure the new pkgs set uses your system's architecture and config
                inherit (pkgs) system;
                config.allowUnfree = true;
              };
        in
        # 2. Use the package from the fetched pkgs, applying your override
        prPkgs.wivrn.override { cudaSupport = true; };
    };
  };
}
