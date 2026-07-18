# NOTE: Tests related to sortArray go here.
{
  lib,
  sortArray,
  testers,
}:
let
  inherit (lib.attrsets) recurseIntoAttrs;
  inherit (testers) shellcheck shfmt testEqualArrayOrMap;
  check =
    {
      expectedArray,
      name,
      valuesArray,
    }:
    (testEqualArrayOrMap {
      inherit name valuesArray expectedArray;

      script = ''
        set -eu
        nixLog "running sortArray with valuesArray to populate actualArray"
        sortArray valuesArray actualArray
      '';
    }).overrideAttrs
      (prevAttrs: {
        nativeBuildInputs = prevAttrs.nativeBuildInputs or [ ] ++ [ sortArray ];
      });

  checkInPlace =
    {
      expectedArray,
      name,
      valuesArray,
    }:
    (testEqualArrayOrMap {
      inherit name valuesArray expectedArray;

      script = ''
        set -eu
        nixLog "running sortArray with valuesArray as input and output"
        sortArray valuesArray valuesArray
        nixLog "copying valuesArray to actualArray"
        actualArray=("''${valuesArray[@]}")
      '';
    }).overrideAttrs
      (prevAttrs: {
        nativeBuildInputs = prevAttrs.nativeBuildInputs or [ ] ++ [ sortArray ];
      });
in
recurseIntoAttrs {
  duplicatesWithSpacesAndLineBreaks = check {
    expectedArray = [
      "bee"
      "bee"
      "cat"
      "cat"
      "dog"
      "dog with spaces"
      "elephant"
      # NOTE: lead whitespace is removed, so the following entries start with `l`.
      ''
        line
        break
      ''
      ''
        line
        break
      ''
      "zebra"
    ];

    name = "duplicatesWithSpacesAndLineBreaks";

    valuesArray = [
      "dog"
      "bee"
      ''
        line
        break
      ''
      "cat"
      "zebra"
      "bee"
      "cat"
      "elephant"
      "dog with spaces"
      ''
        line
        break
      ''
    ];
  };

  duplicatesWithSpacesAndLineBreaksInPlace = checkInPlace {
    expectedArray = [
      "bee"
      "bee"
      "cat"
      "cat"
      "dog"
      "dog with spaces"
      "elephant"
      # NOTE: lead whitespace is removed, so the following entries start with `l`.
      ''
        line
        break
      ''
      ''
        line
        break
      ''
      "zebra"
    ];

    name = "duplicatesWithSpacesAndLineBreaksInPlace";

    valuesArray = [
      "dog"
      "bee"
      ''
        line
        break
      ''
      "cat"
      "zebra"
      "bee"
      "cat"
      "elephant"
      "dog with spaces"
      ''
        line
        break
      ''
    ];
  };

  empty = check {
    expectedArray = [ ];
    name = "empty";
    valuesArray = [ ];
  };

  oneDuplicate = check {
    expectedArray = [
      "apple"
      "apple"
    ];

    name = "oneDuplicate";

    valuesArray = [
      "apple"
      "apple"
    ];
  };

  oneUnique = check {
    expectedArray = [
      "apple"
      "bee"
      "bee"
    ];

    name = "oneUnique";

    valuesArray = [
      "bee"
      "apple"
      "bee"
    ];
  };

  shellcheck = shellcheck {
    src = ./sortArray.bash;
    name = "sortArray";
  };

  shfmt = shfmt {
    src = ./sortArray.bash;
    name = "sortArray";
  };

  singleton = check {
    expectedArray = [ "apple" ];
    name = "singleton";
    valuesArray = [ "apple" ];
  };
}
