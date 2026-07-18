{
  lib,
  stdenv,
  makeSetupHook,
}:

makeSetupHook {
  name = "breakpoint-hook";

  meta = {
    license = lib.licenses.mit;
    broken = !stdenv.buildPlatform.isLinux;
  };
} ./breakpoint-hook.sh
