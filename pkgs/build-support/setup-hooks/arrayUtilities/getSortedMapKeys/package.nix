{
  lib,
  callPackages,
  isDeclaredArray,
  isDeclaredMap,
  makeSetupHook,
  sortArray,
}:
makeSetupHook {
  propagatedBuildInputs = [
    isDeclaredArray
    isDeclaredMap
    sortArray
  ];

  name = "getSortedMapKeys";
  passthru.tests = callPackages ./tests.nix { };

  meta = {
    description = "Gets the sorted indices of an associative array";
    license = lib.licenses.mit;
  };
} ./getSortedMapKeys.bash
