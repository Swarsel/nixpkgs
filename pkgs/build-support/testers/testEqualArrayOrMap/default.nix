{
  lib,
  arrayUtilities,
  stdenvNoCC,
}:
lib.makeOverridable (
  {
    name,
    script,
    expectedArray ? null,
    expectedMap ? null,
    valuesArray ? null,
    valuesMap ? null,
  }:
  assert lib.assertMsg (
    expectedArray != null || expectedMap != null
  ) "testEqualArrayOrMap: at least one of 'expectedArray' or 'expectedMap' must be provided";
  stdenvNoCC.mkDerivation {
    inherit name;
    inherit valuesArray valuesMap;
    inherit expectedArray expectedMap;
    inherit script;
    strictDeps = true;

    nativeBuildInputs = [
      arrayUtilities.isDeclaredArray
      ./assert-equal-array.sh
      arrayUtilities.isDeclaredMap
      arrayUtilities.getSortedMapKeys
      ./assert-equal-map.sh
    ];

    __structuredAttrs = true;
    buildCommandPath = ./build-command.sh;
  }
)
