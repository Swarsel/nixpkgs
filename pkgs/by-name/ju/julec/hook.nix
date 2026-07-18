{
  lib,
  julec,
  makeSetupHook,
}:

makeSetupHook {
  propagatedBuildInputs = [ julec ];
  name = "julec-hook";

  meta = {
    inherit (julec.meta) maintainers;
    license = lib.licenses.mit;
  };
} ./hook.sh
