{ pkgs }:
let
  inherit (pkgs) callPackages callPackage stdenv;
  inherit (pkgs.lib)
    recurseIntoAttrs
    attrNames
    pipe
    hasPrefix
    hasSuffix
    filter
    genAttrs
    optionals
    filterAttrs
    meta
    concatMapAttrs
    optionalAttrs
    ;
  inherit (pkgs.lib.strings) toJSON;
in
{
  # Accumulate all passthru.tests from arrayUtilities into a single attribute set.
  arrayUtilities = recurseIntoAttrs (
    concatMapAttrs (
      name: value:
      optionalAttrs (value ? passthru.tests) {
        ${name} = value.passthru.tests;
      }
    ) pkgs.arrayUtilities
  );

  auto-patchelf-hook = callPackage ./auto-patchelf-hook { };
  auto-patchelf-hook-preserve-origin = callPackage ./auto-patchelf-hook-preserve-origin { };
  auto-patchelf-structured-log = callPackage ./auto-patchelf-structured-log { };
  build-environment-info = callPackage ./build-environment-info { };
  buildFHSEnv = recurseIntoAttrs (callPackages ./buildFHSEnv { });
  buildRustCrate = recurseIntoAttrs (callPackage ../build-support/rust/build-rust-crate/test { });
  buildenv = callPackage ./buildenv.nix { };
  cc-multilib-clang = callPackage ./cc-wrapper/multilib.nix { stdenv = pkgs.clangMultiStdenv; };
  cc-multilib-gcc = callPackage ./cc-wrapper/multilib.nix { stdenv = pkgs.gccMultiStdenv; };

  cc-wrapper =
    let
      pkgNames = (attrNames pkgs);
      llvmTests =
        let
          pkgSets = pipe pkgNames [
            (filter (hasPrefix "llvmPackages"))
            # Are aliases.
            (filter (n: n != "llvmPackages_latest"))
            (filter (n: n != "llvmPackages_9"))
            (filter (n: n != "llvmPackages_10"))
            (filter (n: n != "llvmPackages_11"))
            (filter (n: n != "llvmPackages_12"))
            (filter (n: n != "llvmPackages_13"))
            (filter (n: n != "llvmPackages_14"))
            (filter (n: n != "llvmPackages_15"))
            (filter (n: n != "llvmPackages_16"))
            (filter (n: n != "llvmPackages_17"))
          ];
          tests = genAttrs pkgSets (
            name:
            recurseIntoAttrs {
              clang = callPackage ./cc-wrapper { stdenv = pkgs.${name}.stdenv; };
              libcxx = callPackage ./cc-wrapper { stdenv = pkgs.${name}.libcxxStdenv; };
            }
          );
        in
        tests;
      gccTests =
        let
          pkgSets = pipe (attrNames pkgs) (
            [
              (filter (hasPrefix "gcc"))
              (filter (hasSuffix "Stdenv"))
              (filter (n: n != "gccCrossLibcStdenv"))
              (filter (n: n != "gcc49Stdenv"))
              (filter (n: n != "gcc6Stdenv"))
              (filter (n: n != "gcc7Stdenv"))
              (filter (n: n != "gcc8Stdenv"))
              (filter (n: n != "gcc9Stdenv"))
              (filter (n: n != "gcc10Stdenv"))
              (filter (n: n != "gcc11Stdenv"))
              (filter (n: n != "gcc12Stdenv"))
            ]
            ++
              optionals
                (
                  !(
                    (stdenv.buildPlatform.isLinux && stdenv.buildPlatform.isx86_64)
                    && (stdenv.hostPlatform.isLinux && stdenv.hostPlatform.isx86_64)
                  )
                )
                [
                  (filter (n: !hasSuffix "MultiStdenv" n))
                ]
          );
        in
        genAttrs pkgSets (name: callPackage ./cc-wrapper { stdenv = pkgs.${name}; });
    in
    recurseIntoAttrs {
      default = callPackage ./cc-wrapper { };
      gccTests = recurseIntoAttrs gccTests;
      llvmTests = recurseIntoAttrs llvmTests;

      supported = stdenv.mkDerivation {
        buildCommand = ''
          touch $out
        '';

        builtGCC =
          let
            sets = pipe gccTests [
              (filterAttrs (_: v: meta.availableOn stdenv.hostPlatform v.stdenv.cc))
              # Broken
              (filterAttrs (n: _: n != "gccMultiStdenv"))
            ];
          in
          toJSON sets;

        builtLLVM =
          let
            sets = pipe llvmTests [
              (filterAttrs (_: v: meta.availableOn stdenv.hostPlatform v.clang.stdenv.cc))
              (filterAttrs (_: v: meta.availableOn stdenv.hostPlatform v.libcxx.stdenv.cc))
            ];
          in
          toJSON sets;

        name = "cc-wrapper-supported";
      };
    };

  checkpointBuildTools = callPackage ./checkpointBuild { };
  compress-drv = callPackage ../build-support/compress-drv/test.nix { };
  config = callPackage ./config.nix { };
  coq = callPackage ./coq { };
  cross = recurseIntoAttrs (callPackage ./cross { });
  cuda = callPackage ./cuda { };
  cue-validation = callPackage ./cue { };
  devShellTools = callPackage ../build-support/dev-shell-tools/tests { };
  dhall = callPackage ./dhall { };
  dotnet = recurseIntoAttrs (callPackages ./dotnet { });
  fetchDebianPatch = recurseIntoAttrs (callPackages ../build-support/fetchdebianpatch/tests.nix { });

  fetchFirefoxAddon = recurseIntoAttrs (
    callPackages ../build-support/fetchfirefoxaddon/tests.nix { }
  );

  fetchFromBitbucket = recurseIntoAttrs (callPackages ../build-support/fetchbitbucket/tests.nix { });
  fetchFromGitHub = recurseIntoAttrs (callPackages ../build-support/fetchgithub/tests.nix { });

  fetchNextcloudApp = recurseIntoAttrs (
    callPackages ../build-support/fetchnextcloudapp/tests.nix { }
  );

  fetchPypiLegacy = recurseIntoAttrs (callPackages ../build-support/fetchpypilegacy/tests.nix { });
  fetchgit = recurseIntoAttrs (callPackages ../build-support/fetchgit/tests.nix { });
  fetchpatch = recurseIntoAttrs (callPackages ../build-support/fetchpatch/tests.nix { });

  fetchpatch2 = recurseIntoAttrs (
    callPackages ../build-support/fetchpatch/tests.nix { fetchpatch = pkgs.fetchpatch2; }
  );

  fetchtorrent = recurseIntoAttrs (callPackages ../build-support/fetchtorrent/tests.nix { });
  fetchurl = recurseIntoAttrs (callPackages ../build-support/fetchurl/tests.nix { });
  fetchzip = recurseIntoAttrs (callPackages ../build-support/fetchzip/tests.nix { });
  go = recurseIntoAttrs (callPackage ../build-support/go/tests.nix { });
  hardeningFlags = recurseIntoAttrs (callPackage ./cc-wrapper/hardening.nix { });

  hardeningFlags-clang = recurseIntoAttrs (
    callPackage ./cc-wrapper/hardening.nix {
      stdenv = pkgs.llvmPackages.stdenv;
    }
  );

  hardeningFlags-gcc = recurseIntoAttrs (
    callPackage ./cc-wrapper/hardening.nix {
      stdenv = pkgs.gccStdenv;
    }
  );

  haskell = callPackage ./haskell { };
  home-assistant-components = recurseIntoAttrs pkgs.home-assistant.tests.components;
  hooks = recurseIntoAttrs (callPackage ./hooks { });
  importCargoLock = recurseIntoAttrs (callPackage ../build-support/rust/test/import-cargo-lock { });
  install-shell-files = recurseIntoAttrs (callPackage ./install-shell-files { });
  kernel-config = callPackage ./kernel.nix { };
  lake = callPackage ../build-support/lake/test { };
  ld-library-path = callPackage ./ld-library-path { };
  lib-tests = import ../../lib/tests/release.nix { inherit pkgs; };

  makeBinaryWrapper = callPackage ./make-binary-wrapper {
    makeBinaryWrapper = pkgs.makeBinaryWrapper.override {
      # Enable sanitizers in the tests only, to avoid the performance cost in regular usage.
      # The sanitizers cause errors on aarch64-darwin, see https://github.com/NixOS/nixpkgs/pull/150079#issuecomment-994132734
      sanitizers =
        optionals (!(pkgs.stdenv.hostPlatform.isDarwin && pkgs.stdenv.hostPlatform.isAarch64))
          [
            "undefined"
            "address"
          ];
    };
  };

  makeHardcodeGsettingsPatch = recurseIntoAttrs (callPackage ./make-hardcode-gsettings-patch { });
  makeWrapper = callPackage ./make-wrapper { };
  nixos-functions = callPackage ./nixos-functions { };
  nixosOptionsDoc = recurseIntoAttrs (callPackage ../../nixos/lib/make-options-doc/tests.nix { });
  overriding = callPackage ./overriding.nix { };
  php = recurseIntoAttrs (callPackages ./php { });
  pkg-config = recurseIntoAttrs (callPackage ../top-level/pkg-config/tests.nix { });
  pkgs-lib = recurseIntoAttrs (callPackage ../pkgs-lib/tests { });
  pnpm = recurseIntoAttrs (callPackages ./pnpm { });

  prefer-remote-fetch = recurseIntoAttrs (
    callPackages ../build-support/prefer-remote-fetch/tests.nix { }
  );

  # TODO: Temporarily disabled recursion so we can see the performance comparison in the PR,
  # which only runs if there's exactly the same packages before and after, and this would add packages
  #problems = recurseIntoAttrs (callPackage ./problems { });
  problems = callPackage ./problems { };

  # Accumulate all passthru.tests from qt5 into a single attribute set.
  qt5 = recurseIntoAttrs {
    wrapQtAppsHook = recurseIntoAttrs pkgs.qt5.wrapQtAppsHook.passthru.tests;
  };

  # Accumulate all passthru.tests from qt6 into a single attribute set.
  qt6 = recurseIntoAttrs {
    wrapQtAppsHook = recurseIntoAttrs pkgs.qt6.wrapQtAppsHook.passthru.tests;
  };

  replaceVars = recurseIntoAttrs (callPackage ./replace-vars { });
  rust-hooks = recurseIntoAttrs (callPackages ../build-support/rust/hooks/test { });
  srcOnly = callPackage ../build-support/src-only/tests.nix { };
  stdenv = recurseIntoAttrs (callPackage ./stdenv { });
  stdenv-inputs = callPackage ./stdenv-inputs { };
  substitute = recurseIntoAttrs (callPackage ./substitute { });
  systemd = callPackage ./systemd { };
  testers = callPackage ../build-support/testers/test/default.nix { };
  texlive = recurseIntoAttrs (callPackage ./texlive { });
  top-level = callPackage ./top-level { };
  trivial-builders = callPackage ../build-support/trivial-builders/test/default.nix { };
  vim = callPackage ./vim { };
  vmTools = callPackage ../build-support/vm/test.nix { };
  writers = callPackage ../build-support/writers/test.nix { };
}
