# This is your nixos configuration.
# For home configuration, see /modules/home/*
{
  flake,
  lib,
  pkgs,
  ...
}:
{
  imports = [
    flake.inputs.self.nixosModules.common
    ./services
  ];
  nixpkgs.overlays = [
    flake.inputs.millennium.overlays.default
    # remove this later, needed to rebuild lutris as of April 2026
    (_: prev: {
      openldap = prev.openldap.overrideAttrs {
        doCheck = !prev.stdenv.hostPlatform.isi686;
      };
    })
    # remove this later, aw-core needs peewee 3.x but nixpkgs has 4.x as of Oct 2026
    (_: prev: {
      pythonPackagesExtensions = prev.pythonPackagesExtensions ++ [
        (_: pyprev: {
          aw-core = pyprev.aw-core.override {
            peewee = pyprev.peewee.overridePythonAttrs rec {
              version = "3.19.0";
              src = prev.fetchFromGitHub {
                owner = "coleifer";
                repo = "peewee";
                tag = version;
                hash = "sha256-EO8gS5fMZ1GgJV2YMjy15XQGZa72fZF7dgG7RZUE9dA=";
              };
            };
          };
          # remove this later, test matches an exact TypeError message that newer Cython rewords
          pyopenjtalk-plus = pyprev.pyopenjtalk-plus.overridePythonAttrs (old: {
            disabledTests = (old.disabledTests or [ ]) ++ [
              "test_run_njd_from_mecab_invalid_input_should_not_break_next_call"
            ];
          });
        })
      ];
      # remove this later, speechd's configure can't find python (it's only in buildInputs),
      # so the python bindings calibre imports are silently skipped
      calibre = prev.calibre.override {
        speechd-minimal = prev.speechd-minimal.overrideAttrs (old: {
          nativeBuildInputs = old.nativeBuildInputs ++ [ prev.python314 ];
        });
      };
      # remove this later, unity build merges Qt 6.12's qmlcachegen output with muse code that
      # has muse::extensions::Type in scope, making QQmlPrivate's `Type` ambiguous.
      # only disabled for the affected target; other files rely on unity for missing includes
      audacity = prev.audacity.overrideAttrs (old: {
        postPatch = (old.postPatch or "") + ''
          echo 'set_target_properties(muse_extensions_qml PROPERTIES UNITY_BUILD OFF)' \
            >> muse/framework/extensions/qml/Muse/Extensions/CMakeLists.txt
        '';
      });
      # "--suffix PATH : ..." is passed as a single arg, which makeBinaryWrapper rejects
      aw-qt = prev.aw-qt.overridePythonAttrs {
        makeWrapperArgs = [
          "--suffix"
          "PATH"
          ":"
          (lib.makeBinPath [ prev.xdg-utils ])
        ];
      };
    })
  ];
  services.openssh = {
    enable = true;
    settings = {
      MaxAuthTries = 3;
      LoginGraceTime = 20;
    };
  };
  programs.nix-ld.enable = true; # enable nix ld for all PCs.

  nix.settings.experimental-features = lib.mkForce [
    "nix-command"
    "flakes"
  ];

  # Keep rebuilds from exhausting RAM+swap and freezing the machine.
  # 4 jobs x 3 cores = full use of a 12-thread CPU without 4x12 compilers at once.
  nix.settings = {
    max-jobs = 4;
    cores = 3;
  };
  # Builds still use all CPU, but yield to the desktop when it needs it.
  nix.daemonCPUSchedPolicy = "idle";
  nix.daemonIOSchedClass = "idle";

  # Kill runaway processes on memory pressure before the kernel starts thrashing.
  systemd.oomd = {
    enableRootSlice = true;
    enableSystemSlice = true; # nix-daemon builds run here
    enableUserSlices = true;
  };

  # Compressed swap in RAM; used ahead of any disk swapfile (higher priority).
  zramSwap = {
    enable = true;
    memoryPercent = 50;
  };

  # remove this later
  nixpkgs.config.permittedInsecurePackages = [
    "pnpm-10.29.2"
  ];

  # Allow SSH through the Cloudflare tunnel from any network
  environment.systemPackages = [ pkgs.cloudflared ];
  programs.ssh.extraConfig = ''
    Host ssh.michael-golden.org
      ProxyCommand ${pkgs.cloudflared}/bin/cloudflared access ssh --hostname %h
      User server
  '';
}
