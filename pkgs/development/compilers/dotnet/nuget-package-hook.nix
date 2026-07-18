{
  lib,
  makeSetupHook,
  strip-nondeterminism,
  unzip,
  xmlstarlet,
  zip,
}:
makeSetupHook {
  name = "nuget-package-hook";

  substitutions = {
    inherit unzip zip xmlstarlet;
    stripNondeterminism = strip-nondeterminism;
  };

  meta.license = lib.licenses.mit;
} ./nuget-package-hook.sh
