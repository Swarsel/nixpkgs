{
  lib,
  callPackage,
  makeSetupHook,
}:
makeSetupHook {
  propagatedBuildInputs = [ (callPackage ./package.nix { }) ];
  name = "projucer-hook";

  meta = {
    license = lib.licenses.mit;
    platforms = lib.platforms.linux;
  };
} ./projucer-hook.sh
