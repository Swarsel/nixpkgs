# Run with:
# nix-build -A tests.trivial-builders.writeShellApplication
{
  lib,
  diffutils,
  hello,
  linkFarm,
  runCommand,
  writeShellApplication,
  writeTextFile,
}:
let
  checkShellApplication =
    args@{ expected, name, ... }:
    let
      writeShellApplicationArgs = removeAttrs args [ "expected" ];
      script = writeShellApplication writeShellApplicationArgs;
      executable = lib.getExe script;
      expected' = writeTextFile {
        name = "${name}-expected";
        text = expected;
      };
      actual = "${name}-actual";
    in
    runCommand name { } ''
      echo "Running test executable ${name}"
      ${executable} > ${actual}
      echo "Got output from test executable:"
      cat ${actual}
      echo "Checking test output against expected output:"
      ${diffutils}/bin/diff --color --unified ${expected'} ${actual}
      touch $out
    '';
in
linkFarm "writeShellApplication-tests" {
  test-argument-forwarding = checkShellApplication {
    derivationArgs.MY_BUILD_TIME_VARIABLE = "puppy";

    derivationArgs.postCheck = ''
      if [[ "$MY_BUILD_TIME_VARIABLE" != puppy ]]; then
        echo "\$MY_BUILD_TIME_VARIABLE is not set to 'puppy'!"
        exit 1
      fi
    '';

    expected = "";
    name = "test-argument-forwarding";
    text = "";
    meta.description = "Test checking that `writeShellApplication` forwards extra arguments to `stdenv.mkDerivation`";
  };

  test-bash-options-nounset = checkShellApplication {
    # Don't use `nounset`:
    bashOptions = [ ];
    # Don't warn about the undefined variable at build time:
    excludeShellChecks = [ "SC2154" ];
    expected = "";
    name = "test-bash-options-nounset";

    text = ''
      echo -n "$someUndefinedVariable"
    '';
  };

  test-bash-options-pipefail = checkShellApplication {
    # Don't use `pipefail`:
    bashOptions = [
      "errexit"
      "nounset"
    ];

    expected = "";
    name = "test-bash-options-pipefail";

    text = ''
      touch my-test-file
      echo puppy | grep doggy | sed 's/doggy/puppy/g'
      #            ^^^^^^^^^^ This will fail.
      true
    '';
  };

  test-check-phase = checkShellApplication {
    checkPhase = ''
      echo "echo -n hello" > $target
    '';

    expected = "hello";
    name = "test-check-phase";
    text = "";
  };

  test-exclude-shell-checks = writeShellApplication {
    excludeShellChecks = [ "SC2016" ];
    name = "test-exclude-shell-checks";

    text = ''
      # Triggers SC2016: Expressions don't expand in single quotes, use double
      # quotes for that.
      echo '$SHELL'
    '';
  };

  test-inherit-path-no-runtimeInputs = checkShellApplication {
    expected = "PATH is not empty";
    inheritPath = true;
    name = "test-inherit-path-no-runtimeInputs";
    runtimeInputs = [ ];

    text = ''
      extra_colon_pattern='(^:|:$)'
      if [[ ''${PATH} =~ $extra_colon_pattern ]]; then
        echo "PATH should not start or end with a colon: $PATH"
      fi
      if [[ ''${#PATH} -gt 0 ]]; then
        echo -n "PATH is not empty"
      fi
    '';
  };

  test-meta =
    let
      args = {
        name = "test-meta";
        text = "";
        meta.description = "Test for the `writeShellApplication` `meta` argument";
      };
      script = writeShellApplication args;
    in
    assert script.meta.mainProgram == args.name;
    assert script.meta.description == args.meta.description;
    script;

  test-no-inherit-path-no-runtimeInputs = checkShellApplication {
    expected = "PATH is empty";
    inheritPath = false;
    name = "test-no-inherit-path-no-runtimeInputs";
    runtimeInputs = [ ];

    text = ''
      if [[ ''${#PATH} -eq 0 ]]; then
        echo -n "PATH is empty"
      fi
    '';
  };

  test-no-inherit-path-runtimeInputs = checkShellApplication {
    expected = "PATH is not empty";
    inheritPath = false;
    name = "test-no-inherit-path-runtimeInputs";
    runtimeInputs = [ hello ];

    text = ''
      extra_colon_pattern='(^:|:$)'
      if [[ ''${PATH} =~ $extra_colon_pattern ]]; then
        echo "PATH should not start or end with a colon: $PATH"
      fi
      if [[ ''${#PATH} -gt 0 ]]; then
        echo -n "PATH is not empty"
      fi
    '';
  };

  test-runtime-env = checkShellApplication {
    expected = ''
      my-cool-env-value
      my-other-cool-env-value
    '';

    name = "test-runtime-env";

    runtimeEnv = {
      # Check that we can serialize a bunch of different types:
      BOOL = true;
      INT = 1;

      LIST = [
        1
        2
        3
      ];

      MAP = {
        a = "a";
        b = "b";
      };

      MY_COOL_ENV_VAR = "my-cool-env-value";
      MY_OTHER_COOL_ENV_VAR = "my-other-cool-env-value";
    };

    text = ''
      echo "$MY_COOL_ENV_VAR"
      echo "$MY_OTHER_COOL_ENV_VAR"
    '';
  };

  test-runtime-inputs = checkShellApplication {
    expected = "Hello, world!\n";
    name = "test-runtime-inputs";
    runtimeInputs = [ hello ];

    text = ''
      hello
    '';
  };

}
