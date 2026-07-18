{
  lib,
  makeSetupHook,
  strip-nondeterminism,
}:

makeSetupHook {
  propagatedBuildInputs = [ strip-nondeterminism ];
  name = "strip-java-archives-hook";
  meta.license = lib.licenses.mit;
} ./strip-java-archives.sh
