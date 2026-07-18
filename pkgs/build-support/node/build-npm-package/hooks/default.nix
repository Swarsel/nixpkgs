{
  lib,
  stdenv,
  diffutils,
  installShellFiles,
  jq,
  makeSetupHook,
  makeWrapper,
  nodejs,
  nodejsInstallExecutables,
  nodejsInstallManuals,
  prefetch-npm-deps,
  srcOnly,
}:

{
  npmBuildHook = makeSetupHook {
    name = "npm-build-hook";
    meta.license = lib.licenses.mit;
  } ./npm-build-hook.sh;

  npmConfigHook = makeSetupHook {
    name = "npm-config-hook";

    substitutions = {
      # Specify `diff`, `jq`, and `prefetch-npm-deps` by abspath to ensure that the user's build
      # inputs do not cause us to find the wrong binaries.
      diff = "${diffutils}/bin/diff";
      jq = "${jq}/bin/jq";
      nodeGyp = "${nodejs}/lib/node_modules/npm/node_modules/node-gyp/bin/node-gyp.js";
      nodeSrc = srcOnly nodejs;
      nodeVersion = nodejs.version;
      nodeVersionMajor = lib.versions.major nodejs.version;
      npmArch = stdenv.targetPlatform.node.arch;
      npmPlatform = stdenv.targetPlatform.node.platform;
      prefetchNpmDeps = "${prefetch-npm-deps}/bin/prefetch-npm-deps";
    };

    meta.license = lib.licenses.mit;
  } ./npm-config-hook.sh;

  npmInstallHook = makeSetupHook {
    propagatedBuildInputs = [
      installShellFiles
      makeWrapper
      nodejsInstallManuals
      (nodejsInstallExecutables.override {
        inherit nodejs;
      })
    ];

    name = "npm-install-hook";

    substitutions = {
      jq = "${jq}/bin/jq";
    };

    meta.license = lib.licenses.mit;
  } ./npm-install-hook.sh;
}
