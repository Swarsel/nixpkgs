{
  lib,
  makeSetupHook,
}:

makeSetupHook {
  __structuredAttrs = true;
  name = "omp-checkPhase-hook";
  meta.license = lib.licenses.mit;
} ./omp-check-hook.sh
