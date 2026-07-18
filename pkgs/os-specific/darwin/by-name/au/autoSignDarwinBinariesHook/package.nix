{
  lib,
  makeSetupHook,
  signingUtils,
}:

makeSetupHook {
  propagatedBuildInputs = [ signingUtils ];
  name = "auto-sign-darwin-binaries-hook";
  meta.license = lib.licenses.mit;
} ./auto-sign-hook.sh
