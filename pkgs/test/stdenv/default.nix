# To run these tests:
# nix-build -A tests.stdenv

{
  lib,
  stdenv,
  config,
  pkgs,
  testers,
}:

let
  # tests can be based on builtins.derivation and stage0 or bootstrapTools directly to minimize rebuilds
  # see test 'make-symlinks-relative' in ./hooks.nix as an example.
  initialBash = if stdenv ? stage0 then stdenv.stage0.bash else stdenv.bootstrapTools;
  initialPath = if stdenv ? stage0 then stdenv.stage0.initialPath else [ stdenv.bootstrapTools ];
  # early enough not to rebuild gcc but late enough to have patchelf
  earlyPkgs = stdenv.__bootPackages.stdenv.__bootPackages or pkgs;
  earlierPkgs =
    stdenv.__bootPackages.stdenv.__bootPackages.stdenv.__bootPackages.stdenv.__bootPackages.stdenv.__bootPackages
      or earlyPkgs;
  # use a early stdenv so when hacking on stdenv this test can be run quickly
  bootStdenv = earlyPkgs.stdenv.__bootPackages.stdenv.__bootPackages.stdenv or earlyPkgs.stdenv;
  pkgsStructured = import pkgs.path {
    inherit (stdenv.hostPlatform) system;

    config = config // {
      structuredAttrsByDefault = true;
    };
  };
  bootStdenvStructuredAttrsByDefault =
    pkgsStructured.stdenv.__bootPackages.stdenv.__bootPackages.stdenv.__bootPackages.stdenv.__bootPackages.stdenv
      or pkgsStructured.stdenv;

  runCommand = earlierPkgs.runCommand;

  ccWrapperSubstitutionsTest =
    {
      name,
      stdenv',
      extraAttrs ? { },
    }:

    stdenv'.cc.overrideAttrs (
      previousAttrs:
      (
        {
          inherit name;

          postFixup = previousAttrs.postFixup + ''
            declare -p wrapperName
            echo "env.wrapperName = $wrapperName"
            [[ $wrapperName == "CC_WRAPPER" ]] || (echo "'\$wrapperName' was not 'CC_WRAPPER'" && false)
            declare -p suffixSalt
            echo "env.suffixSalt = $suffixSalt"
            [[ $suffixSalt == "${stdenv'.cc.suffixSalt}" ]] || (echo "'\$suffxSalt' was not '${stdenv'.cc.suffixSalt}'" && false)

            grep -q "@out@" $out/bin/cc || echo "@out@ in $out/bin/cc was substituted"
            grep -q "@suffixSalt@" $out/bin/cc && (echo "$out/bin/cc contains unsubstituted variables" && false)

            touch $out
          '';
        }
        // extraAttrs
      )
    );

  testEnvAttrset =
    {
      name,
      stdenv',
      extraAttrs ? { },
    }:
    stdenv'.mkDerivation (
      {
        inherit name;

        env = {
          string = "testing-string";
        };

        buildCommand = ''
          declare -p string
          echo "env.string = $string"
          [[ $string == "testing-string" ]] || (echo "'\$string' was not 'testing-string'" && false)
          [[ "$(declare -p string)" == 'declare -x string="testing-string"' ]] || (echo "'\$string' was not exported" && false)
          touch $out
        '';

        passAsFile = [ "buildCommand" ];
      }
      // extraAttrs
    );

  testPrependAndAppendToVar =
    {
      name,
      stdenv',
      extraAttrs ? { },
    }:
    stdenv'.mkDerivation (
      {
        inherit name;

        env = {
          string = "testing-string";
        };

        buildCommand = ''
          declare -p string
          appendToVar string hello
          # test that quoted strings work
          prependToVar string "world"
          declare -p string

          declare -A associativeArray=(["X"]="Y")
          [[ $(appendToVar associativeArray "fail" 2>&1) =~ "trying to use" ]] || (echo "appendToVar did not throw appending to associativeArray" && false)
          [[ $(prependToVar associativeArray "fail" 2>&1) =~ "trying to use" ]] || (echo "prependToVar did not throw prepending associativeArray" && false)

          [[ $string == "world testing-string hello" ]] || (echo "'\$string' was not 'world testing-string hello'" && false)

          # test appending to a unset variable
          appendToVar nonExistant created hello
          declare -p nonExistant
          if [[ -n $__structuredAttrs ]]; then
            [[ "''${nonExistant[@]}" == "created hello" ]]
          else
            # there's a extra " " in front here and a extra " " in the end of prependToVar
            # shouldn't matter because these functions will mostly be used for $*Flags and the Flag variable will in most cases already exist
            [[ "$nonExistant" == " created hello" ]]
          fi

          eval "$extraTest"

          touch $out
        '';

        passAsFile = [ "buildCommand" ] ++ lib.optionals (extraAttrs ? extraTest) [ "extraTest" ];
      }
      // extraAttrs
    );

  testConcatTo =
    {
      name,
      stdenv',
      extraAttrs ? { },
    }:
    stdenv'.mkDerivation (
      {
        inherit name;

        buildCommand = ''
          declare -A associativeArray=(["X"]="Y")
          [[ $(concatTo nowhere associativeArray 2>&1) =~ "trying to use" ]] || (echo "concatTo did not throw concatenating associativeArray" && false)

          empty_array=()
          empty_string=""

          declare -a flagsArray
          concatTo flagsArray string list notset=e=f empty_array=g empty_string=h
          declare -p flagsArray
          [[ "''${flagsArray[0]}" == "a" ]] || (echo "'\$flagsArray[0]' was not 'a'" && false)
          [[ "''${flagsArray[1]}" == "*" ]] || (echo "'\$flagsArray[1]' was not '*'" && false)
          [[ "''${flagsArray[2]}" == "c" ]] || (echo "'\$flagsArray[2]' was not 'c'" && false)
          [[ "''${flagsArray[3]}" == "d" ]] || (echo "'\$flagsArray[3]' was not 'd'" && false)
          [[ "''${flagsArray[4]}" == "e=f" ]] || (echo "'\$flagsArray[4]' was not 'e=f'" && false)
          [[ "''${flagsArray[5]}" == "g" ]] || (echo "'\$flagsArray[5]' was not 'g'" && false)
          [[ "''${flagsArray[6]}" == "h" ]] || (echo "'\$flagsArray[6]' was not 'h'" && false)

          # test concatenating to unset variable
          concatTo nonExistant string list notset=e=f empty_array=g empty_string=h
          declare -p nonExistant
          [[ "''${nonExistant[0]}" == "a" ]] || (echo "'\$nonExistant[0]' was not 'a'" && false)
          [[ "''${nonExistant[1]}" == "*" ]] || (echo "'\$nonExistant[1]' was not '*'" && false)
          [[ "''${nonExistant[2]}" == "c" ]] || (echo "'\$nonExistant[2]' was not 'c'" && false)
          [[ "''${nonExistant[3]}" == "d" ]] || (echo "'\$nonExistant[3]' was not 'd'" && false)
          [[ "''${nonExistant[4]}" == "e=f" ]] || (echo "'\$nonExistant[4]' was not 'e=f'" && false)
          [[ "''${nonExistant[5]}" == "g" ]] || (echo "'\$nonExistant[5]' was not 'g'" && false)
          [[ "''${nonExistant[6]}" == "h" ]] || (echo "'\$nonExistant[6]' was not 'h'" && false)

          eval "$extraTest"

          touch $out
        '';

        list = [
          "c"
          "d"
        ];

        passAsFile = [ "buildCommand" ] ++ lib.optionals (extraAttrs ? extraTest) [ "extraTest" ];
        string = "a *";
      }
      // extraAttrs
    );

  testConcatStringsSep =
    { name, stdenv' }:
    stdenv'.mkDerivation {
      inherit name;

      buildCommand = ''
        declare -A associativeArray=(["X"]="Y")
        [[ $(concatStringsSep ";" associativeArray 2>&1) =~ "trying to use" ]] || (echo "concatStringsSep did not throw concatenating associativeArray" && false)

        string="lorem ipsum dolor sit amet"
        stringWithSep="$(concatStringsSep "&" string)"
        [[ "$stringWithSep" == "lorem&ipsum&dolor&sit&amet" ]] || (echo "'\$stringWithSep' was not 'lorem&ipsum&dolor&sit&amet'" && false)

        array=("lorem ipsum" "dolor" "sit amet")
        arrayWithSep="$(concatStringsSep "&" array)"
        [[ "$arrayWithSep" == "lorem ipsum&dolor&sit amet" ]] || (echo "'\$arrayWithSep' was not 'lorem ipsum&dolor&sit amet'" && false)

        array=("lorem ipsum" "dolor" "sit amet")
        arrayWithSep="$(concatStringsSep "++" array)"
        [[ "$arrayWithSep" == "lorem ipsum++dolor++sit amet" ]] || (echo "'\$arrayWithSep' was not 'lorem ipsum++dolor++sit amet'" && false)

        array=("lorem ipsum" "dolor" "sit amet")
        arrayWithSep="$(concatStringsSep " and " array)"
        [[ "$arrayWithSep" == "lorem ipsum and dolor and sit amet" ]] || (echo "'\$arrayWithSep' was not 'lorem ipsum and dolor and sit amet'" && false)

        touch $out
      '';

      # NOTE: Testing with "&" as separator is intentional, because unquoted
      # "&" has a special meaning in the "${var//pattern/replacement}" syntax.
      # Cf. https://github.com/NixOS/nixpkgs/pull/318614#discussion_r1706191919
      passAsFile = [ "buildCommand" ];
    };

  testInputDerivationDep = stdenv.mkDerivation {
    buildCommand = "touch $out";
    name = "test-input-derivation-dependency";
  };
  testInputDerivation =
    attrs:
    (stdenv.mkDerivation (
      attrs
      // {
        buildInputs = [ testInputDerivationDep ];
      }
    )).inputDerivation
    // {
      meta = { };
    };
in

{
  ensure-no-execve-in-setup-sh =
    derivation {
      inherit (stdenv.hostPlatform) system;
      PATH = "${pkgs.strace}/bin:${lib.strings.makeSearchPath "bin" initialPath}";

      args = [
        "-c"
        ''
          countCall() {
            echo "$stats" | tr -s ' ' | grep "$1" | cut -d ' ' -f5
          }

          # prevent setup.sh from running `nproc` when cores=0
          # (this would mess up the syscall stats)
          export NIX_BUILD_CORES=1

          echo "Analyzing setup.sh with strace"
          stats=$(strace -fc bash -c ". ${../../stdenv/generic/setup.sh}" 2>&1)
          echo "$stats" | head -n15

          # fail if execve calls is > 1
          stats=$(strace -fc bash -c ". ${../../stdenv/generic/setup.sh}" 2>&1)
          execveCalls=$(countCall execve)
          if [ "$execveCalls" -gt 1 ]; then
            echo "execve calls: $execveCalls; expected: 1"
            echo "ERROR: setup.sh should not launch additional processes when being sourced"
            exit 1
          else
            echo "setup.sh doesn't launch extra processes when sourcing, as expected"
          fi

          touch $out
        ''
      ];

      builder = "${initialBash}/bin/bash";

      initialPath = initialPath ++ [
        pkgs.strace
      ];

      name = "ensure-no-execve-in-setup-sh";
    }
    // {
      meta = { };
    };

  # tests for hooks in `stdenv.defaultNativeBuildInputs`
  hooks = lib.recurseIntoAttrs (
    import ./hooks.nix {
      inherit initialPath initialBash lib;
      pkgs = earlyPkgs;
      stdenv = bootStdenv;
    }
  );

  outputs-no-out =
    runCommand "outputs-no-out-assert"
      {
        # Assumption: the first output* variable to be configured is
        #   _overrideFirst outputDev "dev" "out"
        expectedMsg = "error: _assignFirst: could not find a non-empty variable whose name to assign to outputDev.\n       The following variables were all unset or empty:\n           dev out";

        result = earlierPkgs.testers.testBuildFailure (
          bootStdenv.mkDerivation {
            outputs = [ "foo" ];
            buildPhase = ":";

            installPhase = ''
              touch $foo
            '';

            NIX_DEBUG = 1;
            name = "outputs-no-out";
          }
        );
      }
      ''
        grep -F "$expectedMsg" $result/testBuildFailure.log >/dev/null
        touch $out
      '';

  # Check that mkDerivation rejects MD5 hashes
  rejectedHashes = lib.recurseIntoAttrs {
    md5 =
      let
        drv = runCommand "md5 outputHash rejected" {
          outputHash = "md5-fPt7dxVVP7ffY3MxkQdwVw==";
        } "true";
      in
      assert !(builtins.tryEval drv).success;
      { };
  };

  structuredAttrsByDefault = lib.recurseIntoAttrs {

    hooks = lib.recurseIntoAttrs (
      import ./hooks.nix {
        inherit initialBash initialPath lib;
        pkgs = earlyPkgs;
        stdenv = bootStdenvStructuredAttrsByDefault;
      }
    );

    test-cc-wrapper-substitutions = ccWrapperSubstitutionsTest {
      name = "test-cc-wrapper-substitutions-structuredAttrsByDefault";
      stdenv' = bootStdenvStructuredAttrsByDefault;
    };

    test-concat-strings-sep = testConcatStringsSep {
      name = "test-concat-strings-sep-structuredAttrsByDefault";
      stdenv' = bootStdenvStructuredAttrsByDefault;
    };

    test-concat-to = testConcatTo {
      extraAttrs = {
        extraTest = ''
          declare -a flagsWithSpaces
          concatTo flagsWithSpaces string listWithSpaces
          declare -p flagsWithSpaces
          [[ "''${flagsWithSpaces[0]}" == "a" ]] || (echo "'\$flagsWithSpaces[0]' was not 'a'" && false)
          [[ "''${flagsWithSpaces[1]}" == "*" ]] || (echo "'\$flagsWithSpaces[1]' was not '*'" && false)
          [[ "''${flagsWithSpaces[2]}" == "c c" ]] || (echo "'\$flagsWithSpaces[2]' was not 'c c'" && false)
          [[ "''${flagsWithSpaces[3]}" == "d d" ]] || (echo "'\$flagsWithSpaces[3]' was not 'd d'" && false)
        '';

        # test that whitespace is kept in the bash array for structuredAttrs
        listWithSpaces = [
          "c c"
          "d d"
        ];
      };

      name = "test-concat-to-structuredAttrsByDefault";
      stdenv' = bootStdenvStructuredAttrsByDefault;
    };

    test-golden-example-structuredAttrs =
      let
        goldenSh = earlyPkgs.writeText "goldenSh" ''
          declare -A EXAMPLE_ATTRS=(['foo']='bar' )
          declare EXAMPLE_BOOL_FALSE=
          declare EXAMPLE_BOOL_TRUE=1
          declare EXAMPLE_INT=123
          declare EXAMPLE_INT_NEG=-123
          declare -a EXAMPLE_LIST=('foo' 'bar' )
          declare EXAMPLE_STR='foo bar'
        '';
        goldenJson = earlyPkgs.writeText "goldenSh" ''
          {
            "EXAMPLE_ATTRS": {
              "foo": "bar"
            },
            "EXAMPLE_BOOL_FALSE": false,
            "EXAMPLE_BOOL_TRUE": true,
            "EXAMPLE_INT": 123,
            "EXAMPLE_INT_NEG": -123,
            "EXAMPLE_LIST": [
              "foo",
              "bar"
            ],
            "EXAMPLE_NESTED_ATTRS": {
              "foo": {
                "bar": "baz"
              }
            },
            "EXAMPLE_NESTED_LIST": [
              [
                "foo",
                "bar"
              ],
              [
                "baz"
              ]
            ],
            "EXAMPLE_STR": "foo bar"
          }
        '';
      in
      bootStdenvStructuredAttrsByDefault.mkDerivation {
        inherit goldenSh;
        inherit goldenJson;
        nativeBuildInputs = [ earlyPkgs.jq ];

        EXAMPLE_ATTRS = {
          foo = "bar";
        };

        EXAMPLE_BOOL_FALSE = false;
        EXAMPLE_BOOL_TRUE = true;
        EXAMPLE_INT = 123;
        EXAMPLE_INT_NEG = -123;

        EXAMPLE_LIST = [
          "foo"
          "bar"
        ];

        EXAMPLE_NESTED_ATTRS = {
          foo.bar = "baz";
        };

        EXAMPLE_NESTED_LIST = [
          [
            "foo"
            "bar"
          ]
          [ "baz" ]
        ];

        EXAMPLE_STR = "foo bar";

        buildCommand = ''
          mkdir -p $out
          cat $NIX_ATTRS_SH_FILE | grep "EXAMPLE" | grep -v -E 'installPhase|jq' > $out/sh
          jq 'with_entries(select(.key|match("EXAMPLE")))' $NIX_ATTRS_JSON_FILE > $out/json
          diff $out/sh $goldenSh
          diff $out/json $goldenJson
        '';

        name = "test-golden-example-structuredAttrsByDefault";
      };

    test-prepend-append-to-var = testPrependAndAppendToVar {
      extraAttrs = {
        # will be a bash associative array(dictionary) in attrs.sh
        # declare -A array=(['a']='1' ['b']='2' )
        # and a json object in attrs.json
        # {"array":{"a":"1","b":"2"}
        array = {
          a = "1";
          b = "2";
        };

        extraTest = ''
          declare -p array
          array+=(["c"]="3")
          declare -p array

          [[ "''${array[c]}" == "3" ]] || (echo "c element of '\$array' was not '3'" && false)

          declare -p list
          prependToVar list hello
          # test that quoted strings work
          appendToVar list "world"
          declare -p list

          [[ "''${list[0]}" == "hello" ]] || (echo "first element of '\$list' was not 'hello'" && false)
          [[ "''${list[1]}" == "a" ]] || (echo "first element of '\$list' was not 'a'" && false)
          [[ "''${list[-1]}" == "world" ]] || (echo "last element of '\$list' was not 'world'" && false)
        '';

        # will be a bash indexed array in attrs.sh
        # declare -a list=('a' 'b' )
        # and a json array in attrs.json
        # "list":["a","b"]
        list = [
          "a"
          "b"
        ];
      };

      name = "test-prepend-append-to-var-structuredAttrsByDefault";
      stdenv' = bootStdenvStructuredAttrsByDefault;
    };

    test-structured-env-attrset = testEnvAttrset {
      name = "test-structured-env-attrset-structuredAttrsByDefault";
      stdenv' = bootStdenvStructuredAttrsByDefault;
    };
  };

  test-cc-wrapper-substitutions = ccWrapperSubstitutionsTest {
    name = "test-cc-wrapper-substitutions";
    stdenv' = bootStdenv;
  };

  test-concat-strings-sep = testConcatStringsSep {
    name = "test-concat-strings-sep";
    stdenv' = bootStdenv;
  };

  test-concat-to = testConcatTo {
    name = "test-concat-to";
    stdenv' = bootStdenv;
  };

  test-env-attrset = testEnvAttrset {
    name = "test-env-attrset";
    stdenv' = bootStdenv;
  };

  test-inputDerivation =
    let
      inherit
        (stdenv.mkDerivation {
          dep1 = derivation {
            inherit (stdenv.buildPlatform) system;

            args = [
              "-c"
              ": > $out"
            ];

            builder = "/bin/sh";
            name = "dep1";
          };

          dep2 = derivation {
            inherit (stdenv.buildPlatform) system;

            args = [
              "-c"
              ": > $out"
            ];

            builder = "/bin/sh";
            name = "dep2";
          };

          passAsFile = [ "dep2" ];
        })
        inputDerivation
        ;
    in
    runCommand "test-inputDerivation"
      {
        exportReferencesGraph = [
          "graph"
          inputDerivation
        ];
      }
      ''
        grep ${inputDerivation.dep1} graph
        grep ${inputDerivation.dep2} graph
        touch $out
      '';

  test-inputDerivation-allowedReferences = testInputDerivation {
    allowedReferences = [ ];
    name = "test-inDrv-allowedReferences";
  };

  test-inputDerivation-allowedRequisites = testInputDerivation {
    allowedRequisites = [ ];
    name = "test-inDrv-allowedRequisites";
  };

  test-inputDerivation-disallowedReferences = testInputDerivation {
    disallowedReferences = [ "${testInputDerivationDep}" ];
    name = "test-inDrv-disallowedReferences";
  };

  test-inputDerivation-disallowedRequisites = testInputDerivation {
    disallowedRequisites = [ "${testInputDerivationDep}" ];
    name = "test-inDrv-disallowedRequisites";
  };

  test-inputDerivation-fixed-output =
    let
      inherit
        (stdenv.mkDerivation {
          buildCommand = ''
            touch $out
          '';

          dep1 = derivation {
            inherit (stdenv.buildPlatform) system;

            args = [
              "-c"
              ": > $out"
            ];

            builder = "/bin/sh";
            name = "dep1";
          };

          dep2 = derivation {
            inherit (stdenv.buildPlatform) system;

            args = [
              "-c"
              ": > $out"
            ];

            builder = "/bin/sh";
            name = "dep2";
          };

          name = "meow";
          outputHash = "sha256-47DEQpj8HBSa+/TImW+5JCeuQeRkm5NMpJWZG3hSuFU=";
          outputHashAlgo = "sha256";
          outputHashMode = "flat";
          passAsFile = [ "dep2" ];
        })
        inputDerivation
        ;
    in
    runCommand "test-inputDerivation"
      {
        exportReferencesGraph = [
          "graph"
          inputDerivation
        ];
      }
      ''
        grep ${inputDerivation.dep1} graph
        grep ${inputDerivation.dep2} graph
        touch $out
      '';

  test-inputDerivation-structured = testInputDerivation {
    __structuredAttrs = true;
    name = "test-inDrv-structured";
  };

  test-inputDerivation-structured-allowedReferences = testInputDerivation {
    __structuredAttrs = true;
    name = "test-inDrv-structured-allowedReferences";
    outputChecks.out.allowedReferences = [ ];
  };

  test-inputDerivation-structured-allowedRequisites = testInputDerivation {
    __structuredAttrs = true;
    name = "test-inDrv-structured-allowedRequisites";
    outputChecks.out.allowedRequisites = [ ];
  };

  test-inputDerivation-structured-disallowedReferences = testInputDerivation {
    __structuredAttrs = true;
    name = "test-inDrv-structured-disallowedReferences";
    outputChecks.out.disallowedReferences = [ "${testInputDerivationDep}" ];
  };

  test-inputDerivation-structured-disallowedRequisites = testInputDerivation {
    __structuredAttrs = true;
    name = "test-inDrv-structured-disallowedRequisites";
    outputChecks.out.disallowedRequisites = [ "${testInputDerivationDep}" ];
  };

  test-prepend-append-to-var = testPrependAndAppendToVar {
    name = "test-prepend-append-to-var";
    stdenv' = bootStdenv;
  };

  test-structured-env-attrset = testEnvAttrset {
    extraAttrs = {
      __structuredAttrs = true;
    };

    name = "test-structured-env-attrset";
    stdenv' = bootStdenv;
  };

  tests-stdenv-gcc-stageCompare = pkgs.callPackage ./gcc-stageCompare.nix { };
}
