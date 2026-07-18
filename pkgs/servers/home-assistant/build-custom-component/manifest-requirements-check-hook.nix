{
  lib,
  makeSetupHook,
  python3Packages,
}:

makeSetupHook {
  name = "manifest-check-hook";

  substitutions = {
    checkManifest = ./check_manifest.py;
    pythonCheckInterpreter = python3Packages.python.interpreter;
  };

  meta.license = lib.licenses.mit;
} ./manifest-requirements-check-hook.sh
