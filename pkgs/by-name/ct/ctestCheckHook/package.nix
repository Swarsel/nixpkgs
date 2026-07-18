{
  lib,
  cmake,
  makeSetupHook,
}:

makeSetupHook {
  propagatedBuildInputs = [ cmake ];
  name = "ctestCheckHook";
  meta.license = lib.licenses.mit;
} ./ctest-check-hook.sh
