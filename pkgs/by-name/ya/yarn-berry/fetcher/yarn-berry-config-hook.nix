{
  lib,
  diffutils,
  makeSetupHook,
  nodejs,
  srcOnly,
  yarn-berry-offline,
}:

makeSetupHook {
  name = "yarn-berry-config-hook";

  substitutions = {
    # Specify `diff` by abspath to ensure that the user's build
    # inputs do not cause us to find the wrong binaries.
    diff = "${diffutils}/bin/diff";
    nodeGyp = "${nodejs}/lib/node_modules/npm/node_modules/node-gyp/bin/node-gyp.js";
    nodeSrc = srcOnly nodejs;
    yarn_offline = "${yarn-berry-offline}/bin/yarn";
  };

  meta = {
    description = "Install nodejs dependencies from an offline yarn cache produced by fetchYarnDeps";
    license = lib.licenses.mit;
  };
} ./yarn-berry-config-hook.sh
