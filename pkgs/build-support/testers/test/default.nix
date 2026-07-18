{
  lib,
  emptyDirectory,
  emptyFile,
  hello,
  pkgs,
  runCommand,
  stdenvNoCC,
  testers,
  ...
}:
let
  pkgs-with-overlay = pkgs.extend (
    final: prev: {
      proof-of-overlay-hello = prev.hello;
    }
  );

  dummyVersioning = {
    label = "test";
    revision = "test";
    versionSuffix = "test";
  };

  overrideStructuredAttrs =
    enable: drv:
    drv.overrideAttrs (old: {
      failed = old.failed.overrideAttrs (oldFailed: {
        __structuredAttrs = enable;
        name = oldFailed.name + "${lib.optionalString (!enable) "-no"}-structuredAttrs";
      });
    });
  runNixOSTest-example = pkgs-with-overlay.testers.runNixOSTest (
    { lib, ... }:
    {
      name = "runNixOSTest-test";

      nodes.machine =
        { pkgs, ... }:
        {
          environment.systemPackages = [
            pkgs.proof-of-overlay-hello
            pkgs.figlet
          ];

          system.nixos = dummyVersioning;
        };

      testScript = ''
        machine.succeed("hello | figlet >/dev/console")
      '';
    }
  );

in
lib.recurseIntoAttrs {
  inherit runNixOSTest-example;
  hasCmakeConfigModules = pkgs.callPackage ../hasCmakeConfigModules/tests.nix { };
  hasPkgConfigModules = pkgs.callPackage ../hasPkgConfigModules/tests.nix { };
  lycheeLinkCheck = lib.recurseIntoAttrs pkgs.lychee.tests;

  # Check that the wiring of nixosTest is correct.
  # Correct operation of the NixOS test driver should be asserted elsewhere.
  nixosTest-example = pkgs-with-overlay.testers.nixosTest (
    { lib, ... }:
    {
      name = "nixosTest-test";

      nodes.machine =
        { pkgs, ... }:
        {
          environment.systemPackages = [
            pkgs.proof-of-overlay-hello
            pkgs.figlet
          ];

          system.nixos = dummyVersioning;
        };

      testScript = ''
        machine.succeed("hello | figlet >/dev/console")
      '';
    }
  );

  runCommand = lib.recurseIntoAttrs {
    bork = pkgs.python3Packages.bork.tests.pytest-network;

    dns-resolution = testers.runCommand {
      nativeBuildInputs = [ pkgs.ldns ];
      name = "runCommand-dns-resolution-test";

      script = ''
        drill example.com
        touch $out
      '';
    };

    nonDefault-hash = testers.runCommand {
      hash = "sha256-eMy+6bkG+KS75u7Zt4PM3APhtdVd60NxmBRN5GKJrHs=";
      name = "runCommand-nonDefaultHash-test";

      script = ''
        mkdir $out
        touch $out/empty
        echo aaaaaaaaaaicjnrkeflncmrlk > $out/keymash
      '';
    };
  };

  runNixOSTest-extendNixOS =
    let
      t = runNixOSTest-example.extendNixOS {
        module =
          { lib, hi, ... }:
          {
            config = {
              assertions = [ { assertion = hi; } ];
            };

            options = {
              itsProofYay = lib.mkOption { };
            };
          };

        specialArgs.hi = true;
      };
    in
    assert lib.isDerivation t;
    assert t.nodes.machine ? itsProofYay;
    t;

  shellcheck = pkgs.callPackage ../shellcheck/tests.nix { };
  shfmt = pkgs.callPackages ../shfmt/tests.nix { };

  testBuildFailure = lib.recurseIntoAttrs rec {
    happy =
      runCommand "testBuildFailure-happy"
        {
          failed = testers.testBuildFailure (
            runCommand "fail" { } ''
              echo ok-ish >$out

              echo failing though
              echo also stderr 1>&2
              echo 'line\nwith-\bbackslashes'
              printf "incomplete line - no newline"

              exit 3
            ''
          );
        }
        ''
          grep -F 'ok-ish' $failed/result

          grep -F 'failing though' $failed/testBuildFailure.log
          grep -F 'also stderr' $failed/testBuildFailure.log
          grep -F 'line\nwith-\bbackslashes' $failed/testBuildFailure.log
          grep -F 'incomplete line - no newline' $failed/testBuildFailure.log

          [[ 3 = $(cat $failed/testBuildFailure.exit) ]]

          touch $out
        '';

    happyStructuredAttrs = overrideStructuredAttrs true happy;

    helloDoesNotFail =
      runCommand "testBuildFailure-helloDoesNotFail"
        {
          # Add hello itself as a prerequisite, so we don't try to run this test if
          # there's an actual failure in hello.
          inherit hello;
          failed = testers.testBuildFailure (testers.testBuildFailure hello);
        }
        ''
          echo "Checking $failed/testBuildFailure.log"
          grep -F 'testBuildFailure: The builder did not fail, but a failure was expected' $failed/testBuildFailure.log >/dev/null
          [[ 1 = $(cat $failed/testBuildFailure.exit) ]]
          touch $out
          echo 'All good.'
        '';

    multiOutput =
      runCommand "testBuildFailure-multiOutput"
        {
          failed = testers.testBuildFailure (
            runCommand "fail"
              {
                # dev will be the default output
                outputs = [
                  "dev"
                  "doc"
                  "out"
                ];
              }
              ''
                echo i am failing
                exit 1
              ''
          );
        }
        ''
          grep -F 'i am failing' $failed/testBuildFailure.log >/dev/null
          [[ 1 = $(cat $failed/testBuildFailure.exit) ]]

          # Checking our note that dev is the default output
          echo $failed/_ | grep -- '-dev/_' >/dev/null
          echo 'All good.'
          touch $out
        '';

    multiOutputStructuredAttrs = overrideStructuredAttrs true multiOutput;
    sideEffectStructuredAttrs = overrideStructuredAttrs true sideEffects;

    sideEffects =
      runCommand "testBuildFailure-sideEffects"
        {
          failed = testers.testBuildFailure (
            stdenvNoCC.mkDerivation {
              src = emptyDirectory;

              buildPhase = ''
                echo i am failing
                exit 1
              '';

              name = "fail-with-side-effects";

              postHook = ''
                echo touching side-effect...
                # Assert that the side-effect doesn't exist yet...
                # We're checking that this hook isn't run by expect-failure.sh
                if [[ -e side-effect ]]; then
                  echo "side-effect already exists"
                  exit 1
                fi
                touch side-effect
              '';
            }
          );
        }
        ''
          grep -F 'touching side-effect...' $failed/testBuildFailure.log >/dev/null
          grep -F 'i am failing' $failed/testBuildFailure.log >/dev/null
          [[ 1 = $(cat $failed/testBuildFailure.exit) ]]
          [[ ! -e side-effect ]]

          touch $out
        '';
  };

  testBuildFailure' = lib.recurseIntoAttrs (
    pkgs.callPackages ../testBuildFailurePrime/tests.nix { inherit overrideStructuredAttrs; }
  );

  testEqualArrayOrMap = pkgs.callPackages ../testEqualArrayOrMap/tests.nix { };

  testEqualContents = lib.recurseIntoAttrs {
    emptyFileAndDir = testers.testBuildFailure (
      testers.testEqualContents {
        actual = emptyDirectory;
        assertion = "Empty file and directory are not recognized as equal";
        expected = emptyFile;
      }
    );

    equalDir = testers.testEqualContents {
      actual = runCommand "actual" { } ''
        mkdir -p -- "$out/c"
        echo a >"$out/a"
        echo b >"$out/b"
        echo d >"$out/c/d"
        echo e >"$out/e"
        chmod a+x -- "$out/e"
      '';

      assertion = "The same directory contents at different paths are recognized as equal";

      expected = runCommand "expected" { } ''
        mkdir -p -- "$out/c"
        echo a >"$out/a"
        echo b >"$out/b"
        echo d >"$out/c/d"
        echo e >"$out/e"
        chmod a+x -- "$out/e"
      '';
    };

    equalExe = testers.testEqualContents {
      actual = runCommand "actual" { } ''
        echo test >"$out"
        chmod a+x -- "$out"
      '';

      assertion = "The same executable file contents at different paths are recognized as equal";

      expected = runCommand "expected" { } ''
        echo test >"$out"
        chmod a+x -- "$out"
      '';
    };

    fileDiff =
      let
        log = testers.testBuildFailure (
          testers.testEqualContents {
            actual = runCommand "actual" { } ''
              mkdir -p "$out/b"
              echo a >"$out/a"
              echo ACTUAL >"$out/b/c"
            '';

            assertion = "Different files are not recognized as equal in subdirectories";

            expected = runCommand "expected" { } ''
              mkdir -p -- "$out/b"
              echo a >"$out/a"
              echo EXPECTED >"$out/b/c"
            '';
          }
        );
      in
      runCommand "testEqualContents-fileDiff" { inherit log; } ''
        (
          set -x
          # Note: use `&&` operator to chain commands because errexit (set -e)
          # does not work in this context (even when set explicitly and with
          # inherit_errexit), otherwise the subshell exits with the status of
          # the last run command and ignores preceding failures.
          grep -F -- 'Contents must be equal, but were not!' "$log/testBuildFailure.log" &&
          grep -E -- '\+\+\+ .*-expected/b/c' "$log/testBuildFailure.log" &&
          grep -E -- '--- .*-actual/b/c' "$log/testBuildFailure.log" &&
          grep -F -- -ACTUAL "$log/testBuildFailure.log" &&
          grep -F -- +EXPECTED "$log/testBuildFailure.log"
        ) || {
          echo "Test failed: could not find pattern in build log $log"
          false
        }
        echo 'All good.'
        touch -- "$out"
      '';

    # - Test whether a missing file triggers a failure as expected
    # - Test the postFailureMessage
    fileMissing =
      let
        log = testers.testBuildFailure (
          testers.testEqualContents {
            inherit postFailureMessage;

            actual = runCommand "actual" { } ''
              mkdir -p -- "$out/c"
              echo a >"$out/a"
              echo d >"$out/c/d"
            '';

            assertion = "Directories with different file list are not recognized as equal";

            expected = runCommand "expected" { } ''
              mkdir -p -- "$out/c"
              echo a >"$out/a"
              echo b >"$out/b"
              echo d >"$out/c/d"
            '';
          }
        );
        postFailureMessage = ''
          If after careful review, you find that the changes are acceptable, run `suchandsuch` to adopt the new behavior.
        '';
      in
      runCommand "fileMissing-failure-and-log-check"
        {
          inherit log;
          inherit postFailureMessage;
        }
        ''
          grep -F "$postFailureMessage" "$log/testBuildFailure.log"
          touch $out
        '';

    nonExistentPath = testers.testBuildFailure (
      testers.testEqualContents {
        actual = "${emptyDirectory}/bar";
        assertion = "Non existent paths are not recognized as equal";
        expected = "${emptyDirectory}/foo";
      }
    );

    unequalExe = testers.testBuildFailure (
      testers.testEqualContents {
        actual = runCommand "actual" { } ''
          touch -- "$out"
        '';

        assertion = "Different file mode bits are not recognized as equal";

        expected = runCommand "expected" { } ''
          touch -- "$out"
          chmod a+x -- "$out"
        '';
      }
    );

    unequalExeInDir = testers.testBuildFailure (
      testers.testEqualContents {
        actual = runCommand "actual" { } ''
          mkdir -p -- "$out/a"
          echo b >"$out/b"
        '';

        assertion = "Different file mode bits are not recognized as equal in directory";

        expected = runCommand "expected" { } ''
          mkdir -p -- "$out/a"
          echo b >"$out/b"
          chmod a+x -- "$out/b"
        '';
      }
    );
  };
}
