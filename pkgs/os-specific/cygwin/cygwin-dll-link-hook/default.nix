{
  lib,
  stdenv,
  binutils-unwrapped,
  callPackage,
  makeSetupHook,
}:
makeSetupHook {
  name = "cygwin-dll-link-hook";

  substitutions = {
    objdump = "${lib.getBin binutils-unwrapped}/${stdenv.targetPlatform.config}/bin/objdump";
  };

  passthru.tests = callPackage ./tests { };
  meta.license = lib.licenses.mit;
} ./cygwin-dll-link.sh
