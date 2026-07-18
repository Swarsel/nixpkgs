{
  lib,
  stdenv,
  buildPackages,
  callPackage,
  diffoscopeMinimal,
  pkgs,
  pkgsLinux,
  replaceVars,
  runCommand,
  runCommandWith,
  stdenvNoCC,
  testers,
}:
# Documentation is in doc/build-helpers/testers.chapter.md
{
  # See https://nixos.org/manual/nixpkgs/unstable/#tester-lycheeLinkCheck
  # or doc/build-helpers/testers.chapter.md
  inherit (callPackage ./lychee.nix { }) lycheeLinkCheck;
  hasCmakeConfigModules = callPackage ./hasCmakeConfigModules/tester.nix { };

  hasPkgConfigModule =
    { moduleName, ... }@args:
    lib.warn
      "testers.hasPkgConfigModule has been deprecated in favor of testers.hasPkgConfigModules. It accepts a list of strings via the moduleNames argument instead of a single moduleName."
      (
        testers.hasPkgConfigModules (
          removeAttrs args [ "moduleName" ]
          // {
            moduleNames = [ moduleName ];
          }
        )
      );

  hasPkgConfigModules = callPackage ./hasPkgConfigModules/tester.nix { };

  # See https://nixos.org/manual/nixpkgs/unstable/#tester-invalidateFetcherByDrvHash
  # or doc/build-helpers/testers.chapter.md
  invalidateFetcherByDrvHash =
    f: args:
    let
      optionalFix = if lib.isFunction args then lib.id else lib.fix;
      unsalted = f args;
      drvPath = unsalted.drvPath;
      # It's safe to discard the context, because we don't access the path.
      salt = builtins.unsafeDiscardStringContext (lib.substring 0 12 (baseNameOf drvPath));
      saltName = name: "${name}-salted-${salt}";
      getSaltedNames =
        args:
        if args.pname or null != null then
          { pname = saltName args.pname; }
        else
          { name = saltName args.name or "source"; };
      # New derivation incorporating the original drv hash in the name
      saltedByArgs = f (optionalFix (lib.extends (lib.toExtension getSaltedNames) (lib.toFunction args)));
      saltedByOverrideAttrs = unsalted.overrideAttrs (previousAttrs: getSaltedNames previousAttrs);
      saltedByOverrideAttrsForced = unsalted.overrideAttrs (previousAttrs: {
        name = saltName unsalted.name;
      });
      # Make sure we did change the derivation.
      # If the fetcher ignores `pname` and `name` and provide a broken `overrideAttrs`,
      # `invalidateFetcherByDrvHash` doesn't work.
      checked =
        if saltedByArgs.drvPath != drvPath then
          saltedByArgs
        else if saltedByOverrideAttrs.drvPath != drvPath then
          saltedByOverrideAttrs
        else if saltedByOverrideAttrsForced.drvPath != drvPath then
          saltedByOverrideAttrsForced
        else
          throw "invalidateFetcherByDrvHash: Neither adding pname/name to the fetcher args nor overriding with overrideAttrs change the result drvPath.";
    in
    checked;

  modularServiceCompliance = callPackage ./modular-service-compliance.nix { };

  # See https://nixos.org/manual/nixpkgs/unstable/#tester-invalidateFetcherByDrvHash
  # or doc/build-helpers/testers.chapter.md
  nixosTest =
    let
      /*
        The nixos/lib/testing-python.nix module, preapplied with arguments that
        make sense for this evaluation of Nixpkgs.
      */
      nixosTesting = (
        import ../../../nixos/lib/testing-python.nix {
          inherit (stdenv.hostPlatform) system;
          inherit pkgs;

          extraConfigurations = [
            (
              { lib, ... }:
              {
                config.nixpkgs.pkgs = lib.mkDefault pkgsLinux;
              }
            )
          ];
        }
      );
    in
    test:
    let
      loadedTest = if builtins.typeOf test == "path" then import test else test;
      calledTest = lib.toFunction loadedTest pkgs;
    in
    nixosTesting.simpleTest calledTest;

  # See https://nixos.org/manual/nixpkgs/unstable/#tester-runCommand
  runCommand = testers.invalidateFetcherByDrvHash (
    {
      stdenv ? stdenvNoCC,
      name,
      script,
      hash ? pkgs.emptyFile.outputHash,
      ...
    }@args:

    runCommandWith {
      inherit name stdenv;

      derivationArgs = {
        outputHash = hash;
        outputHashMode = "recursive";
      }
      // lib.removeAttrs args [
        "hash"
        "name"
        "script"
        "stdenv"
      ];
    } script
  );

  # See https://nixos.org/manual/nixpkgs/unstable/#tester-runNixOSTest
  # or doc/build-helpers/testers.chapter.md
  runNixOSTest =
    let
      nixos = import ../../../nixos/lib {
        inherit lib;
      };
    in
    testModule:
    nixos.runTest {
      _file = "pkgs.runNixOSTest implementation";
      hostPkgs = pkgs;

      imports = [
        (lib.setDefaultModuleLocation "the argument that was passed to pkgs.runNixOSTest" testModule)
      ];

      node.pkgs = pkgsLinux;
    };

  shellcheck = callPackage ./shellcheck/tester.nix { };
  shfmt = callPackage ./shfmt { };

  # See https://nixos.org/manual/nixpkgs/unstable/#tester-testBuildFailure
  # or doc/build-helpers/testers.chapter.md
  testBuildFailure =
    drv:
    drv.overrideAttrs (orig: {
      args = [
        (replaceVars ./expect-failure.sh {
          coreutils = buildPackages.coreutils;

          vars = lib.toShellVars {
            outputNames = (orig.outputs or [ "out" ]);
          };
        })
        orig.realBuilder or stdenv.shell
      ]
      ++ orig.args or [
        "-e"
        ../../stdenv/generic/source-stdenv.sh
        (orig.builder or ../../stdenv/generic/default-builder.sh)
      ];

      builder = buildPackages.bash;
    });

  # See https://nixos.org/manual/nixpkgs/unstable/#tester-testBuildFailurePrime
  # or doc/build-helpers/testers.chapter.md
  testBuildFailure' = callPackage ./testBuildFailurePrime { };
  # See https://nixos.org/manual/nixpkgs/unstable/#tester-testEqualArrayOrMap
  # or doc/build-helpers/testers.chapter.md
  testEqualArrayOrMap = callPackage ./testEqualArrayOrMap { };

  # See https://nixos.org/manual/nixpkgs/unstable/#tester-testEqualContents
  # or doc/build-helpers/testers.chapter.md
  testEqualContents =
    {
      actual,
      assertion,
      expected,
      checkMetadata ? true,
      postFailureMessage ? null,
    }:
    runCommand "equal-contents-${lib.strings.toLower assertion}"
      {
        inherit
          assertion
          actual
          expected
          postFailureMessage
          ;

        nativeBuildInputs = [ diffoscopeMinimal ];
        excludeMetadata = if checkMetadata then "no" else "yes";
      }
      ''
        echo "Checking:"
        printf '%s\n' "$assertion"
        if ! diffoscope --no-progress --text-color=always --exclude-directory-metadata="$excludeMetadata" -- "$actual" "$expected"
        then
          echo
          echo 'Contents must be equal, but were not!'
          if [[ -n "''${postFailureMessage:-}" ]]; then
            echo
            echo "$postFailureMessage"
          fi
          echo
          echo "+: expected,   at $expected"
          echo "-: unexpected, at $actual"
          false
        else
          echo "expected $expected and actual $actual match."
          echo OK
          touch -- "$out"
        fi
      '';

  # See https://nixos.org/manual/nixpkgs/unstable/#tester-testEqualDerivation
  # or doc/build-helpers/testers.chapter.md
  testEqualDerivation = callPackage ./test-equal-derivation.nix { };
  testMetaPkgConfig = callPackage ./testMetaPkgConfig/tester.nix { };

  # See https://nixos.org/manual/nixpkgs/unstable/#tester-testVersion
  # or doc/build-helpers/testers.chapter.md
  testVersion =
    {
      package,
      command ? "${package.meta.mainProgram or package.pname or package.name} --version",
      version ? package.version,
    }:
    runCommand "${package.name}-test-version"
      {
        nativeBuildInputs = [ package ];
        meta.timeout = 60;
      }
      ''
        if output=$(${command} 2>&1 | sed -e 's|${builtins.storeDir}/[^/ ]*/|{{storeDir}}/|g'); then
          if grep -Fw -- "${version}" - <<< "$output"; then
            touch $out
          else
            echo "Version string '${version}' not found!" >&2
            echo "The output was:" >&2
            echo "$output" >&2
            exit 1
          fi
        else
          echo -n ${lib.escapeShellArg command} >&2
          echo " returned a non-zero exit code." >&2
          echo "$output" >&2
          exit 1
        fi
      '';
}
