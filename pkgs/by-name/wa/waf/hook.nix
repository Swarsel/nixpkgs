{
  lib,
  makeSetupHook,
  waf,
}:

makeSetupHook {
  name = "waf-setup-hook";

  substitutions = {
    # Sometimes the upstream provides its own waf file; in order to honor it,
    # waf is not inserted into propagatedBuildInputs, rather it is inserted
    # directly
    inherit waf;
  };

  meta = {
    inherit (waf.meta) maintainers platforms broken;
    description = "Setup hook for using Waf in Nixpkgs";
    license = lib.licenses.mit;
  };
} ./setup-hook.sh
