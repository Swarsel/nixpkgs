{
  lib,
  buildPackages,
  cacert,
  jq,
  makeSetupHook,
  writeShellApplication,
}:

let
  php-script-utils = writeShellApplication {
    name = "php-script-utils";
    runtimeInputs = [ jq ];
    text = builtins.readFile ./php-script-utils.bash;
  };
in
{
  composerInstallHook = makeSetupHook {
    propagatedBuildInputs = [
      cacert
    ];

    name = "composer-install-hook.sh";

    propagatedNativeBuildInputs = [
      jq
    ];

    substitutions = {
      # Specify the stdenv's `diff` by abspath to ensure that the user's build
      # inputs do not cause us to find the wrong `diff`.
      cmp = "${lib.getBin buildPackages.diffutils}/bin/cmp";
      phpScriptUtils = lib.getExe php-script-utils;
    };

    meta.license = lib.licenses.mit;
  } ./composer-install-hook.sh;

  composerRepositoryHook = makeSetupHook {
    propagatedBuildInputs = [
      cacert
    ];

    name = "composer-repository-hook.sh";

    propagatedNativeBuildInputs = [
      jq
    ];

    substitutions = {
      phpScriptUtils = lib.getExe php-script-utils;
    };

    meta.license = lib.licenses.mit;
  } ./composer-repository-hook.sh;

  composerWithPluginVendorHook = makeSetupHook {
    propagatedBuildInputs = [
      cacert
    ];

    name = "composer-with-plugin-vendor-hook.sh";

    propagatedNativeBuildInputs = [
      jq
    ];

    substitutions = {
      # Specify the stdenv's `diff` by abspath to ensure that the user's build
      # inputs do not cause us to find the wrong `diff`.
      cmp = "${lib.getBin buildPackages.diffutils}/bin/cmp";
      phpScriptUtils = lib.getExe php-script-utils;
    };

    meta.license = lib.licenses.mit;
  } ./composer-with-plugin-vendor-hook.sh;
}
