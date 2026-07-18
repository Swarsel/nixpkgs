# NOTE: We must use `pkgs.runCommand` instead of `testers.runCommand` for negative tests -- those wrapped with
# `testers.testBuildFailure`. This is due to the fact that `testers.testBuildFailure` modifies the derivation such that
# it produces an output containing the exit code, logs, and other things. Since `testers.runCommand` expects the empty
# derivation, it produces a hash mismatch.
{ lib, testers }:
let
  inherit (lib.attrsets) recurseIntoAttrs;
  inherit (testers) testBuildFailure' testEqualArrayOrMap;
  concatValuesArrayToActualArray = ''
    nixLog "appending all values in valuesArray to actualArray"
    for value in "''${valuesArray[@]}"; do
      actualArray+=( "$value" )
    done
  '';
  concatValuesMapToActualMap = ''
    nixLog "adding all values in valuesMap to actualMap"
    for key in "''${!valuesMap[@]}"; do
      actualMap["$key"]="''${valuesMap["$key"]}"
    done
  '';
in
recurseIntoAttrs {
  array-append = testEqualArrayOrMap {
    expectedArray = [
      "apple"
      "bee"
      "cat"
      "dog"
    ];

    name = "testEqualArrayOrMap-array-append";

    script = ''
      ${concatValuesArrayToActualArray}
      actualArray+=( "dog" )
    '';

    valuesArray = [
      "apple"
      "bee"
      "cat"
    ];
  };

  array-empty = testEqualArrayOrMap {
    expectedArray = [ ];
    name = "testEqualArrayOrMap-array-empty";

    script = ''
      # doing nothing
    '';

    valuesArray = [
      "apple"
      "bee"
      "cat"
    ];
  };

  array-missing-value = testBuildFailure' {
    drv = testEqualArrayOrMap {
      expectedArray = [ ];
      name = "testEqualArrayOrMap-array-missing-value";
      script = concatValuesArrayToActualArray;
      valuesArray = [ "apple" ];
    };

    expectedBuilderLogEntries = [
      "ERROR: assertEqualArray: arrays differ in length: expectedArray has length 0 but actualArray has length 1"
      "ERROR: assertEqualArray: arrays differ at index 0: expectedArray has no such index but actualArray has value 'apple'"
    ];
  };

  array-prepend = testEqualArrayOrMap {
    expectedArray = [
      "dog"
      "apple"
      "bee"
      "cat"
    ];

    name = "testEqualArrayOrMap-array-prepend";

    script = ''
      actualArray+=( "dog" )
      ${concatValuesArrayToActualArray}
    '';

    valuesArray = [
      "apple"
      "bee"
      "cat"
    ];
  };

  # NOTE: This particular test is used in the docs:
  # See https://nixos.org/manual/nixpkgs/unstable/#tester-testEqualArrayOrMap
  # or doc/build-helpers/testers.chapter.md
  docs-test-function-add-cowbell = testEqualArrayOrMap {
    expectedArray = [
      "cowbell"
      "cowbell"
      "cowbell"
    ];

    name = "test-function-add-cowbell";

    script = ''
      addCowbell() {
        local -rn arrayNameRef="$1"
        arrayNameRef+=( "cowbell" )
      }

      nixLog "appending all values in valuesArray to actualArray"
      for value in "''${valuesArray[@]}"; do
        actualArray+=( "$value" )
      done

      nixLog "applying addCowbell"
      addCowbell actualArray
    '';

    valuesArray = [
      "cowbell"
      "cowbell"
    ];
  };

  map-extra-key = testBuildFailure' {
    drv = testEqualArrayOrMap {
      expectedMap = {
        apple = "0";
        bee = "1";
        dog = "3";
      };

      name = "testEqualArrayOrMap-map-extra-key";
      script = concatValuesMapToActualMap;

      valuesMap = {
        apple = "0";
        bee = "1";
        cat = "2";
        dog = "3";
      };
    };

    expectedBuilderLogEntries = [
      "ERROR: assertEqualMap: maps differ in length: expectedMap has length 3 but actualMap has length 4"
      "ERROR: assertEqualMap: maps differ at key 'cat': expectedMap has no such key but actualMap has value '2'"
    ];
  };

  map-insert = testEqualArrayOrMap {
    expectedMap = {
      apple = "0";
      bee = "1";
      cat = "2";
      dog = "3";
    };

    name = "testEqualArrayOrMap-map-insert";

    script = ''
      ${concatValuesMapToActualMap}
      actualMap["dog"]="3"
    '';

    valuesMap = {
      apple = "0";
      bee = "1";
      cat = "2";
    };
  };

  map-missing-key = testBuildFailure' {
    drv = testEqualArrayOrMap {
      expectedMap = {
        apple = "0";
        bee = "1";
        cat = "2";
        dog = "3";
      };

      name = "testEqualArrayOrMap-map-missing-key";
      script = concatValuesMapToActualMap;

      valuesMap = {
        bee = "1";
        cat = "2";
        dog = "3";
      };
    };

    expectedBuilderLogEntries = [
      "ERROR: assertEqualMap: maps differ in length: expectedMap has length 4 but actualMap has length 3"
      "ERROR: assertEqualMap: maps differ at key 'apple': expectedMap has value '0' but actualMap has no such key"
    ];
  };

  map-missing-key-with-empty = testBuildFailure' {
    drv = testEqualArrayOrMap {
      expectedMap.apple = 1;
      name = "testEqualArrayOrMap-map-missing-key-with-empty";
      script = "";
      valuesArray = [ ];
    };

    expectedBuilderLogEntries = [
      "ERROR: assertEqualMap: maps differ in length: expectedMap has length 1 but actualMap has length 0"
      "ERROR: assertEqualMap: maps differ at key 'apple': expectedMap has value '1' but actualMap has no such key"
    ];
  };

  map-remove = testEqualArrayOrMap {
    expectedMap = {
      apple = "0";
      cat = "2";
      dog = "3";
    };

    name = "testEqualArrayOrMap-map-remove";

    script = ''
      ${concatValuesMapToActualMap}
      unset 'actualMap[bee]'
    '';

    valuesMap = {
      apple = "0";
      bee = "1";
      cat = "2";
      dog = "3";
    };
  };
}
