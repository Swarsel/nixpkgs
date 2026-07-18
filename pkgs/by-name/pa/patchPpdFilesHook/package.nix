{
  lib,
  callPackage,
  makeSetupHook,
  which,
}:

makeSetupHook {
  name = "patch-ppd-files";

  substitutions = {
    awkscript = ./patch-ppd-lines.awk;
    which = lib.getBin which;
  };

  passthru.tests.test = callPackage ./test.nix { };

  meta = {
    description = "Setup hook to patch executable paths in ppd files";
    license = lib.licenses.mit;
    maintainers = [ lib.maintainers.yarny ];
  };
} ./patch-ppd-hook.sh
