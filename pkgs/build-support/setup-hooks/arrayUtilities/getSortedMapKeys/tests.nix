# NOTE: Tests related to getSortedMapKeys go here.
{
  lib,
  getSortedMapKeys,
  testers,
}:
let
  inherit (lib.attrsets) recurseIntoAttrs;
  inherit (testers) shellcheck shfmt testEqualArrayOrMap;

  check =
    {
      expectedArray,
      name,
      valuesMap,
    }:
    (testEqualArrayOrMap {
      inherit name valuesMap expectedArray;

      script = ''
        set -eu
        nixLog "running getSortedMapKeys with valuesMap to populate actualArray"
        getSortedMapKeys valuesMap actualArray
      '';
    }).overrideAttrs
      (prevAttrs: {
        nativeBuildInputs = prevAttrs.nativeBuildInputs or [ ] ++ [ getSortedMapKeys ];
      });
in
recurseIntoAttrs {
  empty = check {
    expectedArray = [ ];
    name = "empty";
    valuesMap = { };
  };

  keysAreSorted = check {
    expectedArray = [
      "apple"
      "bee"
      "carrot"
    ];

    name = "keysAreSorted";

    valuesMap = {
      "apple" = "fruit";
      "bee" = "insect";
      "carrot" = "vegetable";
    };
  };

  # NOTE: While keys can be whitespace, they cannot be null (empty).
  keysCanBeWhitespace = check {
    expectedArray = [
      " "
      "  "
    ];

    name = "keysCanBeWhitespace";

    valuesMap = {
      " " = 1;
      "  " = 2;
    };
  };

  shellcheck = shellcheck {
    src = ./getSortedMapKeys.bash;
    name = "getSortedMapKeys";
  };

  shfmt = shfmt {
    src = ./getSortedMapKeys.bash;
    name = "getSortedMapKeys";
  };

  singleton = check {
    expectedArray = [ "apple" ];
    name = "singleton";

    valuesMap = {
      "apple" = "fruit";
    };
  };
}
