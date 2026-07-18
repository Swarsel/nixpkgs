{
  lib,
  coreutils,
  makeSetupHook,
}:

makeSetupHook {
  name = "version-check-hook";

  substitutions = {
    envCommand = lib.getExe' coreutils "env"; # Cannot call it env, because it isn't an attrset of environment variables!
    storeDir = builtins.storeDir;
  };

  meta = {
    description = "Lookup for $version in the output of --help and --version";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ doronbehar ];
  };
} ./hook.sh
