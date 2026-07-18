{
  lib,
  bash,
  makeSetupHook,
  patchcil,
}:

makeSetupHook {
  name = "auto-patchcil-hook";

  substitutions = {
    patchcil = lib.getExe patchcil;
    shell = lib.getExe bash;
  };

  meta.license = lib.licenses.mit;
} ./auto-patchcil.sh
