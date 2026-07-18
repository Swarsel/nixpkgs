{
  lib,
  pkgs,
  stdenvNoCC,
}:

let
  inherit (pkgs) buildEnv;

  testingThrow = expr: {
    expected = {
      success = false;
      value = false;
    };

    expr = (builtins.tryEval (builtins.seq expr "didn't throw"));
  };

  tests-name = {
    testNameFromNameArg = {
      expected = "test-env";

      expr =
        (buildEnv {
          name = "test-env";
          paths = [ ];
        }).name;
    };

    testNameFromPnameVersion = {
      expected = "test-env-1.0";

      expr =
        (buildEnv {
          pname = "test-env";
          version = "1.0";
          paths = [ ];
        }).name;
    };
  };

  tests-passthru-paths = {
    testPassthruPathsOverridable = {
      expected = true;

      expr =
        let
          env = buildEnv {
            name = "test-env";
            paths = [ pkgs.hello ];
          };
          overridden = env.overrideAttrs {
            passthru.paths = [ pkgs.figlet ];
          };
        in
        builtins.length overridden.paths == 1;
    };

    testPathsInPassthru = {
      expected = true;

      expr =
        let
          env = buildEnv {
            name = "test-env";
            paths = [ pkgs.hello ];
          };
        in
        builtins.length env.paths > 0;
    };
  };

  tests-finalAttrs = {
    testFinalAttrsSelfReference = {
      expected = "An env named test-env";

      expr =
        let
          env = buildEnv (finalAttrs: {
            name = "test-env";
            paths = [ ];
            passthru.description = "An env named ${finalAttrs.name}";
          });
        in
        env.description;
    };
  };

  tests-overrideAttrs =
    let
      base = buildEnv {
        name = "test-env";
        paths = [ pkgs.hello ];
        passthru.custom = "original";
      };
      overridden = base.overrideAttrs (
        finalAttrs: prev: {
          passthru = prev.passthru // {
            custom = "modified";
          };
        }
      );
    in
    {
      testOverrideAttrsAffectsDrv = {
        expected = true;

        expr =
          let
            withPostBuild = base.overrideAttrs { postBuild = "echo overridden"; };
          in
          base.drvPath != withPostBuild.drvPath;
      };

      testOverrideAttrsChangesPassthru = {
        expected = "modified";
        expr = overridden.custom;
      };

      testOverrideAttrsPreservesName = {
        expected = "test-env";
        expr = overridden.name;
      };
    };

  tests-passthru-merging =
    let
      env = buildEnv {
        derivationArgs.passthru.fromDerivationArgs = "a";
        name = "test-env";
        paths = [ pkgs.hello ];
        passthru.fromPassthru = "b";
      };
    in
    {
      testPassthruMergingAutoPathsPresent = {
        expected = true;
        expr = env ? paths;
      };

      testPassthruMergingDerivationArgs = {
        expected = "a";
        expr = env.fromDerivationArgs;
      };

      testPassthruMergingDirectPassthru = {
        expected = "b";
        expr = env.fromPassthru;
      };

      # Direct passthru takes precedence over derivationArgs.passthru
      testPassthruMergingPrecedence = {
        expected = "from-passthru";

        expr =
          let
            env' = buildEnv {
              derivationArgs.passthru.key = "from-derivationArgs";
              name = "test-env";
              paths = [ ];
              passthru.key = "from-passthru";
            };
          in
          env'.key;
      };
    };

  tests-derivationArgs =
    let
      env = buildEnv {
        derivationArgs.allowSubstitutes = true;
        name = "test-env";
        paths = [ ];
      };
    in
    {
      # Backward compat: top-level nativeBuildInputs still works
      testCompatNativeBuildInputs = {
        expected = true;

        expr =
          let
            env' = buildEnv {
              nativeBuildInputs = [ pkgs.hello ];
              name = "test-env";
              paths = [ ];
            };
          in
          builtins.length env'.nativeBuildInputs > 0;
      };

      # derivationArgs.allowSubstitutes overrides the default (false)
      testDerivationArgsForwarded = {
        expected = true;
        expr = env.allowSubstitutes;
      };
    };

  # Build tests: derivations that build a buildEnv and verify its output.
  # These are exposed via passthru.buildTests and checked in buildCommand.
  buildTests = {
    postBuild =
      pkgs.runCommand "test-buildenv-postBuild"
        {
          testEnv = buildEnv {
            postBuild = ''
              echo "postBuild was here" > $out/marker
            '';

            name = "test-env";
            paths = [ ];
          };
        }
        ''
          # postBuild should have created the marker file
          test -f "$testEnv/marker" || { echo "FAIL: $testEnv/marker missing; postBuild did not run"; exit 1; }
          content=$(cat "$testEnv/marker")
          test "$content" = "postBuild was here" || { echo "FAIL: marker content wrong: $content"; exit 1; }

          touch $out
        '';

    basic-symlinking =
      pkgs.runCommand "test-buildenv-basic-symlinking"
        {
          testEnv = buildEnv {
            name = "test-env";
            paths = [ pkgs.hello ];
          };
        }
        ''
          # With a single package, buildEnv symlinks the directory itself
          test -L "$testEnv/bin" || { echo "FAIL: $testEnv/bin is not a symlink"; exit 1; }

          # The symlink should point into the store
          target=$(readlink "$testEnv/bin")
          case "$target" in
            /nix/store/*) ;;
            *) echo "FAIL: symlink target '$target' is not a store path"; exit 1 ;;
          esac

          # The binary should be accessible and executable through the symlink
          test -x "$testEnv/bin/hello" || { echo "FAIL: hello binary not executable"; exit 1; }
          "$testEnv/bin/hello" > /dev/null || { echo "FAIL: hello binary did not run"; exit 1; }

          touch $out
        '';

    extraPrefix =
      pkgs.runCommand "test-buildenv-extraPrefix"
        {
          testEnv = buildEnv {
            extraPrefix = "/myprefix";
            name = "test-env";
            paths = [ pkgs.hello ];
          };
        }
        ''
          # Content should be under the extra prefix
          test -e "$testEnv/myprefix/bin/hello" || { echo "FAIL: $testEnv/myprefix/bin/hello missing"; exit 1; }
          test -x "$testEnv/myprefix/bin/hello" || { echo "FAIL: $testEnv/myprefix/bin/hello not executable"; exit 1; }

          # Content should NOT be at the top level
          test ! -e "$testEnv/bin" || { echo "FAIL: $testEnv/bin should not exist at top level with extraPrefix"; exit 1; }

          touch $out
        '';

    ignoreCollisions =
      pkgs.runCommand "test-buildenv-ignoreCollisions"
        {
          # Two copies of hello with different priorities that collide
          testEnv = buildEnv {
            ignoreCollisions = true;
            name = "test-env-ignore";

            paths = [
              pkgs.hello
              (lib.meta.setPrio 1 pkgs.hello)
            ];
          };
        }
        ''
          # Should succeed because ignoreCollisions = true
          test -x "$testEnv/bin/hello" || { echo "FAIL: hello not present with ignoreCollisions"; exit 1; }

          touch $out
        '';

    pathsToLink =
      pkgs.runCommand "test-buildenv-pathsToLink"
        {
          testEnv = buildEnv {
            name = "test-env";
            paths = [ pkgs.hello ];
            pathsToLink = [ "/bin" ];
          };
        }
        ''
          # /bin should exist
          test -d "$testEnv/bin" || { echo "FAIL: $testEnv/bin missing"; exit 1; }

          # Other directories from hello (like /share) should NOT exist
          test ! -e "$testEnv/share" || { echo "FAIL: $testEnv/share should not exist with pathsToLink = [\"/bin\"]"; exit 1; }

          touch $out
        '';

    # buildEnv explicitly sets __structuredAttrs = true because builder.pl
    # reads all inputs from `$NIX_ATTRS_JSON_FILE`.
    # Verify the build succeeds even when derivationArgs tries to disable structuredAttrs.
    structuredAttrs-overridden =
      pkgs.runCommand "test-buildenv-structuredAttrs-overridden"
        {
          testEnv = buildEnv {
            derivationArgs.__structuredAttrs = false;
            name = "test-env-structuredAttrs";
            paths = [ pkgs.hello ];
          };
        }
        ''
          test -x "$testEnv/bin/hello" || { echo "FAIL: hello not present after structuredAttrs override"; exit 1; }
          touch $out
        '';
  };

  # buildEnv's builder.pl reads all inputs from `$NIX_ATTRS_JSON_FILE`,
  # which requires __structuredAttrs = true.
  # buildEnv explicitly forces __structuredAttrs = true.
  tests-structuredAttrs = {
    testStructuredAttrsCantBeOverriddenViaDerivationArgs = {
      expected = true;

      expr =
        (buildEnv {
          derivationArgs.__structuredAttrs = false;
          name = "test-env";
          paths = [ ];
        }).__structuredAttrs;
    };

    testStructuredAttrsExplicitlyFalse = {
      expected = true;

      expr =
        (buildEnv {
          name = "test-env";
          paths = [ ];
        }).__structuredAttrs;
    };
  };

  tests =
    tests-name
    // tests-passthru-paths
    // tests-finalAttrs
    // tests-overrideAttrs
    // tests-passthru-merging
    // tests-derivationArgs
    // tests-structuredAttrs;
in

stdenvNoCC.mkDerivation (finalAttrs: {
  __structuredAttrs = true;

  buildCommand = ''
    touch $out
    for testName in "''${!testResults[@]}"; do
      if [[ -n "''${testResults[$testName]}" ]]; then
        echo "$testName success"
      else
        echo "$testName fail"
      fi
    done
  ''
  + lib.optionalString (lib.any (v: !v) (lib.attrValues finalAttrs.testResults)) ''
    {
      echo "ERROR: tests.buildenv: Encountering failed tests."
      for testName in "''${!testResults[@]}"; do
        if [[ -z "''${testResults[$testName]}" ]]; then
          echo "- $testName"
        fi
      done
      echo "To inspect the expected and actual result, "
      echo '  evaluate `tests.buildenv.tests.''${testName}`.'
    } >&2
    exit 1
  '';

  name = "test-buildenv";
  testResults = lib.mapAttrs (_: test: test.expr == test.expected) finalAttrs.passthru.tests;

  passthru = {
    inherit tests buildTests;
    failures = lib.runTests finalAttrs.passthru.tests;
  };
})
