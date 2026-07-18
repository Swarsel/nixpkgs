{
  lib,
  dart,
  jq,
  makeSetupHook,
  python3,
  yq,
}:

{
  dartBuildHook = makeSetupHook {
    name = "dart-build-hook";
    substitutions.jq = "${jq}/bin/jq";
    substitutions.yq = "${yq}/bin/yq";
    meta.license = lib.licenses.mit;
  } ./dart-build-hook.sh;

  dartConfigHook = makeSetupHook {
    name = "dart-config-hook";
    substitutions.jq = "${jq}/bin/jq";
    substitutions.packageGraphScript = ../../pub2nix/package-graph.py;
    substitutions.python3 = lib.getExe (python3.withPackages (ps: with ps; [ pyyaml ]));
    substitutions.workspacePackageConfigScript = ../workspace-package-config.py;
    substitutions.yq = "${yq}/bin/yq";
    meta.license = lib.licenses.mit;
  } ./dart-config-hook.sh;

  dartFixupHook = makeSetupHook {
    name = "dart-fixup-hook";
    meta.license = lib.licenses.mit;
  } ./dart-fixup-hook.sh;

  dartInstallHook = makeSetupHook {
    name = "dart-install-hook";
    meta.license = lib.licenses.mit;
  } ./dart-install-hook.sh;
}
