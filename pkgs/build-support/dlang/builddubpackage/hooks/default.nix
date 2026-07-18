{ lib, callPackage }:

{
  dubBuildHook = callPackage (
    { dub, makeSetupHook }:
    makeSetupHook {
      propagatedBuildInputs = [ dub ];
      name = "dub-build-hook";
      meta.license = lib.licenses.mit;
    } ./dub-build-hook.sh
  ) { };

  dubCheckHook = callPackage (
    { dub, makeSetupHook }:
    makeSetupHook {
      propagatedBuildInputs = [ dub ];
      name = "dub-check-hook";
      meta.license = lib.licenses.mit;
    } ./dub-check-hook.sh
  ) { };

  dubSetupHook = callPackage (
    { makeSetupHook }:
    makeSetupHook {
      name = "dub-setup-hook";
      meta.license = lib.licenses.mit;
    } ./dub-setup-hook.sh
  ) { };
}
