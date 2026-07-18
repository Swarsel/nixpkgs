{
  lib,
  stdenv,
  devShellTools,
  emptyFile,
  hello,
  nixosTests,
  writeText,
  zlib,
}:
let
  inherit (lib)
    concatLines
    escapeShellArg
    isString
    mapAttrsToList
    ;
in
lib.recurseIntoAttrs {

  # nix-build -A tests.devShellTools.nixos
  nixos = nixosTests.docker-tools-nix-shell;

  # nix-build -A tests.devShellTools.valueToString
  unstructuredDerivationInputEnv =
    let
      inherit (devShellTools) unstructuredDerivationInputEnv;

      drvAttrs = {
        aPackageAttrSet = hello;
        anAnAlternateOutput = zlib.dev;
        anOutPath = hello.outPath;

        args = [
          "args must not be added to the environment"
          "Nix doesn't do it."
        ];

        bar = ''
          bar
          ${writeText "qux" "yea"}
        '';

        boolFalse = false;
        boolTrue = true;
        foo = "foo";

        list = [
          1
          2
          3
        ];

        one = 1;
        passAsFile = [ "bar" ];
        pathDefaultNix = ./default.nix;
        stringWithDep = "Exe: ${hello}/bin/hello";
      };
      result = unstructuredDerivationInputEnv { inherit drvAttrs; };
    in
    assert
      result // { barPath = "<check later>"; } == {
        aPackageAttrSet = "${hello}";
        anAnAlternateOutput = "${zlib.dev}";
        anOutPath = "${hello.outPath}";
        barPath = "<check later>";
        boolFalse = "";
        boolTrue = "1";
        foo = "foo";
        list = "1 2 3";
        one = "1";
        passAsFile = "bar";
        pathDefaultNix = "${./default.nix}";
        stringWithDep = "Exe: ${hello}/bin/hello";
      };

    # Not runCommand, because it alters `passAsFile`
    stdenv.mkDerivation (
      {
        doCheck = true;

        checkPhase = ''
          fail() {
            echo "$@" >&2
            exit 1
          }
          checkAttr() {
            echo checking attribute $1...
            if [[ "$2" != "$3" ]]; then
              echo "expected: $3"
              echo "actual: $2"
              exit 1
            fi
          }
          ${concatLines (
            mapAttrsToList (name: value: "checkAttr ${name} \"\$${name}\" ${escapeShellArg value}") (
              removeAttrs result [
                "args"

                # Nix puts it in workdir, which is not a concept for
                # unstructuredDerivationInputEnv, so we have to put it in the
                # store instead. This means the full path won't match.
                "barPath"
              ]
            )
          )}
          (
            set -x

            diff $exampleBarPathString $barPath
          )

          ''${args:+fail "args should not be set by Nix. We don't expect it to and unstructuredDerivationInputEnv removes it."}
          if [[ "''${builder:-x}" == x ]]; then
            fail "builder should be set by Nix. We don't remove it in unstructuredDerivationInputEnv."
          fi
        '';

        installPhase = "touch $out";
        dontBuild = true;
        dontFixup = true;
        dontUnpack = true;

        exampleBarPathString =
          assert isString result.barPath;
          result.barPath;

        name = "devShellTools-unstructuredDerivationInputEnv-built-tests";
      }
      // removeAttrs drvAttrs [
        # This would break the derivation. Instead, we have a check in the derivation to make sure Nix doesn't set it.
        "args"
      ]
    );

  # nix-build -A tests.devShellTools.valueToString
  valueToString =
    let
      inherit (devShellTools) valueToString;
    in

    stdenv.mkDerivation {
      # Test inputs
      inherit emptyFile hello;
      boolFalse = false;
      boolTrue = true;

      # TODO: nested lists
      buildCommand = ''
        touch $out
        ( set -x
          [[ "$one" = ${escapeShellArg (valueToString 1)} ]]
          [[ "$boolTrue" = ${escapeShellArg (valueToString true)} ]]
          [[ "$boolFalse" = ${escapeShellArg (valueToString false)} ]]
          [[ "$foo" = ${escapeShellArg (valueToString "foo")} ]]
          [[ "$hello" = ${escapeShellArg (valueToString hello)} ]]
          [[ "$list" = ${
            escapeShellArg (valueToString [
              1
              2
              3
            ])
          } ]]
          [[ "$packages" = ${
            escapeShellArg (valueToString [
              hello
              emptyFile
            ])
          } ]]
          [[ "$pathDefaultNix" = ${escapeShellArg (valueToString ./default.nix)} ]]
          [[ "$emptyFile" = ${escapeShellArg (valueToString emptyFile)} ]]
        ) >log 2>&1 || { cat log; exit 1; }
      '';

      foo = "foo";

      list = [
        1
        2
        3
      ];

      name = "devShellTools-valueToString-built-tests";
      one = 1;

      packages = [
        hello
        emptyFile
      ];

      pathDefaultNix = ./default.nix;
    };
}
