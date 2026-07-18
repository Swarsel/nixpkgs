{
  lib,
  stdenv,
  crun,
  git,
  gnutar,
  gzip,
  haskell,
  haskellPackages,
  makeBinaryWrapper,
  nixos,
  openssh,
  testers,
}:
let
  inherit (haskell.lib.compose) overrideCabal addBuildTools justStaticExecutables;
  inherit (lib) makeBinPath;
  bundledBins = [
    gnutar
    gzip
    git
    openssh
  ]
  ++ lib.optional stdenv.hostPlatform.isLinux crun;

  pkg =
    # justStaticExecutables is needed due to https://github.com/NixOS/nix/issues/2990
    overrideCabal (o: {
      postInstall = ''
        ${o.postInstall or ""}
        ${lib.optionalString (stdenv.hostPlatform.isDarwin && stdenv.hostPlatform.isAarch64) ''
          remove-references-to -t ${haskellPackages.hercules-ci-cnix-expr} $out/bin/hercules-ci-agent
          remove-references-to -t ${haskellPackages.hercules-ci-cnix-expr} $out/bin/hercules-ci-agent-worker
        ''}
        mkdir -p $out/libexec
        mv $out/bin/hercules-ci-agent $out/libexec
        makeWrapper $out/libexec/hercules-ci-agent $out/bin/hercules-ci-agent --prefix PATH : ${lib.escapeShellArg (makeBinPath bundledBins)}
      '';
    }) (addBuildTools [ makeBinaryWrapper ] (justStaticExecutables haskellPackages.hercules-ci-agent));
in
pkg.overrideAttrs (
  finalAttrs: o: {
    passthru = o.passthru // {
      tests = {
        version = testers.testVersion {
          command = "hercules-ci-agent --help";
          package = finalAttrs.finalPackage;
        };
      }
      // lib.optionalAttrs (stdenv.hostPlatform.isLinux) {
        nixos-many-options-config =
          (nixos (
            { pkgs, ... }:
            {
              boot.loader.grub.enable = false;
              fileSystems."/".device = "bogus";

              services.hercules-ci-agent = {
                enable = true;
                package = pkgs.hercules-ci-agent;

                settings = {
                  apiBaseUrl = "https://hci.dev.biz.example.com";
                  binaryCachesPath = "/var/keys/binary-caches.json";
                  concurrentTasks = 42;
                  labels.foo.bar.baz = "qux";

                  labels.qux = [
                    "q"
                    "u"
                  ];

                  workDirectory = "/var/tmp/hci";
                };
              };

              # Dummy value for testing only.
              system.stateVersion = lib.trivial.release; # TEST ONLY
            }
          )).config.system.build.toplevel;

        # Does not test the package, but evaluation of the related NixOS module.
        nixos-simple-config =
          (nixos {
            boot.loader.grub.enable = false;
            fileSystems."/".device = "bogus";
            services.hercules-ci-agent.enable = true;
            # Dummy value for testing only.
            system.stateVersion = lib.trivial.release; # TEST ONLY
          }).config.system.build.toplevel;
      };
    };

    meta = o.meta // {
      position = toString ./package.nix + ":1";
    };
  }
)
