{
  lib,
  makeSetupHook,
  targetPackages,
}:

makeSetupHook {
  name = "fix-darwin-dylib-names-hook";
  substitutions = { inherit (targetPackages.stdenv.cc) targetPrefix; };

  meta = {
    license = lib.licenses.mit;
    platforms = lib.platforms.darwin;
  };
} ./fix-darwin-dylib-names.sh
