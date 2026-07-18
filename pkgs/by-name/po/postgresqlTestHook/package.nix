{
  lib,
  callPackage,
  makeSetupHook,
}:

makeSetupHook {
  name = "postgresql-test-hook";

  passthru.tests = {
    simple = callPackage ./test.nix { };
  };

  meta = {
    license = lib.licenses.mit;
    # See comment in postgresql's generic.nix doInstallCheck section.
    badPlatforms = lib.platforms.darwin;
  };
} ./postgresql-test-hook.sh
