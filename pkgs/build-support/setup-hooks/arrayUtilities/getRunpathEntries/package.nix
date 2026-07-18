{
  lib,
  callPackages,
  isDeclaredArray,
  makeSetupHook,
  patchelf,
}:
makeSetupHook {
  propagatedBuildInputs = [
    isDeclaredArray
    patchelf
  ];

  name = "getRunpathEntries";
  passthru.tests = callPackages ./tests.nix { };

  meta = {
    description = "Appends runpath entries of a file to an array";
    license = lib.licenses.mit;
  };
} ./getRunpathEntries.bash
