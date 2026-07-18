{
  lib,
  callPackage,
  makeSetupHook,
  nodejs,
  srcOnly,
}:
{
  linkNodeModulesHook = makeSetupHook {
    name = "node-modules-hook.sh";

    substitutions = {
      nodejs = lib.getExe nodejs;
      script = ./link-node-modules.js;
      storePrefix = builtins.storeDir;
    };

    meta.license = lib.licenses.mit;
  } ./link-node-modules-hook.sh;

  npmConfigHook = makeSetupHook {
    name = "npm-config-hook";

    substitutions = {
      canonicalizeSymlinksScript = ./canonicalize-symlinks.js;
      nodeGyp = "${nodejs}/lib/node_modules/npm/node_modules/node-gyp/bin/node-gyp.js";
      nodeSrc = srcOnly nodejs;
      storePrefix = builtins.storeDir;
    };

    meta.license = lib.licenses.mit;
  } ./npm-config-hook.sh;
}
