{
  lib,
  makeWrapper,
  runCommand,
  which,
  writeCBin,
  writeShellScript,
  writeText,
  ...
}:

let
  # Testfiles
  foofile = writeText "foofile" "foo";
  barfile = writeText "barfile" "bar";

  # Wrapped binaries
  wrappedArgv0 = writeCBin "wrapped-argv0" ''
    #include <stdio.h>
    #include <stdlib.h>

    void main(int argc, char** argv) {
      printf("argv0=%s", argv[0]);
      exit(0);
    }
  '';
  wrappedBinaryVar = writeShellScript "wrapped-var" ''
    echo "VAR=$VAR"
  '';
  wrappedBinaryArgs = writeShellScript "wrapped-args" ''
    printf '%s\n' "$@"
  '';

  mkWrapperBinary =
    {
      args,
      name,
      wrapped ? wrappedBinaryVar,
    }:
    runCommand name
      {
        nativeBuildInputs = [ makeWrapper ];
      }
      ''
        mkdir -p $out/bin
        makeWrapper "${wrapped}" "$out/bin/${name}" ${lib.escapeShellArgs args}
      '';

  mkArgTest = cmd: toExpect: mkTest cmd (builtins.concatStringsSep "\n" toExpect);
  mkTest = cmd: toExpect: ''
    output="$(${cmd})"
    if [[ "$output" != ${lib.escapeShellArg toExpect} ]]; then
      echo "test failed: the output of ${cmd} was '$output', expected ${lib.escapeShellArg toExpect}"
      echo "the wrapper contents:"
      for i in ${cmd}; do
        if [[ $i =~ ^test- ]]; then
          cat $(which $i)
        fi
      done
      exit 1
    fi
  '';
in
runCommand "make-wrapper-test"
  {
    nativeBuildInputs = [
      which
      (mkWrapperBinary {
        args = [
          "--argv0"
          "foo"
        ];

        name = "test-argv0";
        wrapped = "${wrappedArgv0}/bin/wrapped-argv0";
      })
      (mkWrapperBinary {
        args = [
          "--set"
          "VAR"
          "abc"
        ];

        name = "test-set";
      })
      (mkWrapperBinary {
        args = [
          "--set-default"
          "VAR"
          "abc"
        ];

        name = "test-set-default";
      })
      (mkWrapperBinary {
        args = [
          "--unset"
          "VAR"
        ];

        name = "test-unset";
      })
      (mkWrapperBinary {
        args = [
          "--run"
          "echo bar"
        ];

        name = "test-run";
      })
      (mkWrapperBinary {
        args = [
          "--run"
          "export VAR=foo"
          "--set"
          "VAR"
          "bar"
        ];

        name = "test-run-and-set";
      })
      (mkWrapperBinary {
        args = [
          "--add-flags"
          "abc"
          "--append-flags"
          "xyz"
        ];

        name = "test-args";
        wrapped = wrappedBinaryArgs;
      })
      (mkWrapperBinary {
        args = [
          "--add-flag"
          "abc 'aaaaa' jkhhjk"
          "--append-flag"
          "xyz ggg"
        ];

        name = "test-arg";
        wrapped = wrappedBinaryArgs;
      })
      (mkWrapperBinary {
        args = [
          "--prefix"
          "VAR"
          ":"
          "abc"
        ];

        name = "test-prefix";
      })
      (mkWrapperBinary {
        args = [
          "--prefix"
          "VAR"
          ":"
          "./*"
        ];

        name = "test-prefix-noglob";
      })
      (mkWrapperBinary {
        args = [
          "--suffix"
          "VAR"
          ":"
          "abc"
        ];

        name = "test-suffix";
      })
      (mkWrapperBinary {
        args = [
          "--prefix"
          "VAR"
          ":"
          "foo"
          "--suffix"
          "VAR"
          ":"
          "bar"
        ];

        name = "test-prefix-and-suffix";
      })
      (mkWrapperBinary {
        args = [
          "--prefix"
          "VAR"
          ":"
          "abc:foo:foo"
        ];

        name = "test-prefix-multi";
      })
      (mkWrapperBinary {
        args = [
          "--suffix-each"
          "VAR"
          ":"
          "foo bar:def"
        ];

        name = "test-suffix-each";
      })
      (mkWrapperBinary {
        args = [
          "--prefix-each"
          "VAR"
          ":"
          "foo bar:def"
        ];

        name = "test-prefix-each";
      })
      (mkWrapperBinary {
        args = [
          "--suffix-contents"
          "VAR"
          ":"
          "${foofile} ${barfile}"
        ];

        name = "test-suffix-contents";
      })
      (mkWrapperBinary {
        args = [
          "--prefix-contents"
          "VAR"
          ":"
          "${foofile} ${barfile}"
        ];

        name = "test-prefix-contents";
      })
    ];
  }
  (
    # --argv0 works
    mkTest "test-argv0" "argv0=foo"

    # --set works
    + mkTest "test-set" "VAR=abc"
    # --set overwrites the variable
    + mkTest "VAR=foo test-set" "VAR=abc"
    # --set-default works
    + mkTest "test-set-default" "VAR=abc"
    # --set-default doesn"t overwrite the variable
    + mkTest "VAR=foo test-set-default" "VAR=foo"
    # --unset works
    + mkTest "VAR=foo test-unset" "VAR="

    # --add-flags and --append-flags work
    + mkArgTest "test-args" [
      "abc"
      "xyz"
    ]
    # --add-flag and --append-flag work
    + mkArgTest "test-arg" [
      "abc 'aaaaa' jkhhjk"
      "xyz ggg"
    ]
    # given flags are kept
    + mkArgTest "test-args foo" [
      "abc"
      "foo"
      "xyz"
    ]

    # --run works
    + mkTest "test-run" "bar\nVAR="
    # --run & --set works
    + mkTest "test-run-and-set" "VAR=bar"

    # --prefix works
    + mkTest "VAR=foo test-prefix" "VAR=abc:foo"
    # sets variable if not set yet
    + mkTest "test-prefix" "VAR=abc"
    # prepends value only once
    + mkTest "VAR=abc test-prefix" "VAR=abc"
    # Moves value to the front if it already existed
    + mkTest "VAR=foo:abc test-prefix" "VAR=abc:foo"
    + mkTest "VAR=abc:foo:bar test-prefix-multi" "VAR=abc:foo:bar"
    # Doesn't overwrite parts of the string
    + mkTest "VAR=test:abcde:test test-prefix" "VAR=abc:test:abcde:test"
    # Only append the value once when given multiple times in a parameter
    # to makeWrapper
    + mkTest "test-prefix" "VAR=abc"
    # --prefix doesn't expand globs
    + mkTest "VAR=f?oo test-prefix-noglob" "VAR=./*:f?oo"

    # --suffix works
    + mkTest "VAR=foo test-suffix" "VAR=foo:abc"
    # sets variable if not set yet
    + mkTest "test-suffix" "VAR=abc"
    # adds the same value only once
    + mkTest "VAR=abc test-suffix" "VAR=abc"
    + mkTest "VAR=abc:foo test-suffix" "VAR=abc:foo"
    # --prefix in combination with --suffix
    + mkTest "VAR=abc test-prefix-and-suffix" "VAR=foo:abc:bar"

    # --suffix-each works
    + mkTest "VAR=abc test-suffix-each" "VAR=abc:foo:bar:def"
    # --prefix-each works
    + mkTest "VAR=abc test-prefix-each" "VAR=bar:def:foo:abc"
    # --suffix-contents works
    + mkTest "VAR=abc test-suffix-contents" "VAR=abc:foo:bar"
    # --prefix-contents works
    + mkTest "VAR=abc test-prefix-contents" "VAR=bar:foo:abc"
    + "touch $out"
  )
