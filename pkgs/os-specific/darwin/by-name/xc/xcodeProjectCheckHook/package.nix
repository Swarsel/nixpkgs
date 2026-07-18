{
  lib,
  makeSetupHook,
  pkgsBuildHost,
}:

makeSetupHook {
  propagatedBuildInputs = [ pkgsBuildHost.openssl ];
  name = "xcode-project-check-hook";
  meta.license = lib.licenses.mit;
} ./setup-hook.sh
