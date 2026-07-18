{
  lib,
  makeBinaryWrapper,
  makeSetupHook,
}:

makeSetupHook {
  propagatedBuildInputs = [ makeBinaryWrapper ];
  name = "wrapGNUstepAppsHook";
  meta.license = lib.licenses.mit;
} ./wrapGNUstepAppsHook.sh
