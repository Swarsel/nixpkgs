{
  lib,
  coreutils,
  gnugrep,
  stdenvNoCC,
  writeShellApplication,
  writeShellScript,
}:

/**
  See https://nixos.org/manual/nixpkgs/unstable/#tester-modularServiceCompliance
  or doc/build-helpers/testers.chapter.md
*/
{
  evalConfig,
  mkTest,
  sharedDir,
  namePrefix ? "modular-service-compliance",
}:

let

  /**
    A successful evaluation to be probed by evalTestDefs
  */
  # Try use only few evalConfig calls for performance.
  evalResult = evalConfig {
    services = {
      svc = {
        assertions = [
          {
            assertion = true;
            message = "compliance test assertion";
          }
        ];

        process.argv = [ "${coreutils}/bin/true" ];

        services.child = {
          assertions = [
            {
              assertion = true;
              message = "compliance child assertion";
            }
          ];

          process.argv = [ "${coreutils}/bin/true" ];
          warnings = [ "compliance child warning" ];
        };

        warnings = [ "compliance test warning" ];
      };
    };
  };

  evalTestDefs =
    let
      c = evalResult.config.svc;
    in
    {
      testAssertions = {
        expected = true;

        expr = builtins.elem {
          assertion = true;
          message = "compliance test assertion";
        } c.assertions;
      };

      # Separate eval for a failing assertion — checkDrv would fail here,
      # so we only access config.
      testFailingAssertionValue = {
        expected = true;

        expr = builtins.elem {
          assertion = false;
          message = "compliance failing assertion";
        } failingEval.config.failing.assertions;
      };

      testProcessArgv = {
        expected = [ "${coreutils}/bin/true" ];
        expr = c.process.argv;
      };

      testSubServiceArgv = {
        expected = [ "${coreutils}/bin/true" ];
        expr = c.services.child.process.argv;
      };

      testSubServiceAssertions = {
        expected = true;

        expr = builtins.elem {
          assertion = true;
          message = "compliance child assertion";
        } c.services.child.assertions;
      };

      testSubServiceWarnings = {
        expected = true;
        expr = builtins.elem "compliance child warning" c.services.child.warnings;
      };

      testWarnings = {
        expected = true;
        expr = builtins.elem "compliance test warning" c.warnings;
      };
    };

  failingEval = evalConfig {
    services = {
      failing = {
        assertions = [
          {
            assertion = false;
            message = "compliance failing assertion";
          }
        ];

        process.argv = [ "${coreutils}/bin/true" ];
      };
    };
  };

  /**
    A service script that records its received arguments, then sleeps forever.
    The first argument is a service identifier used to namespace its comms
    subdirectory; the remaining arguments are recorded as the service's args.
  */
  svc = writeShellScript "${namePrefix}-svc" ''
    id="$1"; shift
    dir="${sharedDir}/$id"
    mkdir -p "$dir"
    echo "$$" > "$dir/pid"
    printf '%s\n' "$@" > "$dir/args"
    exec "${coreutils}/bin/sleep" infinity
  '';

  mkArgv =
    id: extraArgs:
    [
      svc
      id
    ]
    ++ extraArgs;

  /**
    Shell snippet: wait for a service to write its pid file, verify the
    process is still alive, then check that each expected argument appears
    in the recorded args file.
  */
  waitAndCheck =
    id: expectedArgs:
    ''
      echo "waiting for ${id}..."
      timeout=30; elapsed=0
      while [ ! -f "${sharedDir}/${id}/pid" ] && [ "$elapsed" -lt "$timeout" ]; do
        sleep 1; elapsed=$((elapsed + 1))
      done
      test -f "${sharedDir}/${id}/pid" || { echo "${id}: no pid file after ''${timeout}s"; exit 1; }
      pid=$(cat "${sharedDir}/${id}/pid")
      kill -0 "$pid" || { echo "${id}: pid $pid is not running"; exit 1; }
      echo "${id}: started (pid $pid)"
    ''
    + lib.concatMapStrings (arg: ''
      grep -qxF -- ${lib.escapeShellArg arg} "${sharedDir}/${id}/args" \
        || { echo "${id}: expected arg ${lib.escapeShellArg arg} not found"; cat "${sharedDir}/${id}/args"; exit 1; }
    '') expectedArgs;

  mkTestScript =
    name: text:
    lib.getExe (writeShellApplication {
      inherit text;
      name = "${namePrefix}-${name}";

      runtimeInputs = [
        coreutils
        gnugrep
      ];
    });

in
{
  # Integration tests: verify that services actually run.
  basic-argv = mkTest {
    name = "${namePrefix}-basic-argv";

    services.test.process.argv = mkArgv "test" [
      "--greeting"
      "hello"
    ];

    testExe = mkTestScript "basic-argv" (
      waitAndCheck "test" [
        "--greeting"
        "hello"
      ]
    );
  };

  # Eval-level tests: config structure, evaluated in the integration's
  # full context (one whole-system eval).
  # TODO: generalize with
  #   - pkgs/test/buildenv.nix
  #   - pkgs/test/overriding.nix
  eval = stdenvNoCC.mkDerivation (finalAttrs: {
    __structuredAttrs = true;

    buildCommand = ''
      touch $out
      for testName in "''${!testResults[@]}"; do
        if [[ -n "''${testResults[$testName]}" ]]; then
          echo "PASS  $testName"
        else
          echo "FAIL  $testName"
        fi
      done
    ''
    + lib.optionalString (lib.any (v: !v) (lib.attrValues finalAttrs.testResults)) ''
      {
        echo ""
        echo "Eval-level compliance failures:"
        for testName in "''${!testResults[@]}"; do
          if [[ -z "''${testResults[$testName]}" ]]; then
            echo "- $testName"
          fi
        done
        echo ""
        echo 'Inspect with: nix eval .#<path>.tests.''${testName}'
      } >&2
      exit 1
    '';

    name = "${namePrefix}-eval-report";
    # Depend on the integration's representative derivation to prove that
    # the system builds with these services.
    representative = evalResult.checkDrv;
    testResults = lib.mapAttrs (_: test: test.expr == test.expected) finalAttrs.passthru.tests;

    passthru = {
      failures = lib.runTests finalAttrs.passthru.tests;
      tests = evalTestDefs;
    };
  });

  sub-services = mkTest {
    name = "${namePrefix}-sub-services";

    services.a = {
      process.argv = mkArgv "a" [ "--depth=0" ];

      services.b = {
        process.argv = mkArgv "b" [ "--depth=1" ];
        services.c.process.argv = mkArgv "c" [ "--depth=2" ];
      };
    };

    testExe = mkTestScript "sub-services" ''
      ${waitAndCheck "a" [ "--depth=0" ]}
      ${waitAndCheck "b" [ "--depth=1" ]}
      ${waitAndCheck "c" [ "--depth=2" ]}
    '';
  };
  # See also the manual compliance items in doc/build-helpers/testers.chapter.md.
}
