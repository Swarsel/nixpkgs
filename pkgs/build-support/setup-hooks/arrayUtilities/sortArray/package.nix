{
  lib,
  callPackages,
  isDeclaredArray,
  makeSetupHook,
}:
makeSetupHook {
  propagatedBuildInputs = [ isDeclaredArray ];
  name = "sortArray";
  passthru.tests = callPackages ./tests.nix { };

  meta = {
    description = "Sorts an array";
    license = lib.licenses.mit;
  };
} ./sortArray.bash
