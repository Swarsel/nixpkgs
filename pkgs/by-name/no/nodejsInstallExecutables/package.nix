{
  lib,
  installShellFiles,
  jq,
  makeSetupHook,
  makeWrapper,
  nodejs,
}:

makeSetupHook {
  propagatedBuildInputs = [
    installShellFiles
    makeWrapper
  ];

  name = "nodejs-install-executables";

  substitutions = {
    hostNode = "${nodejs}/bin/node";
    jq = "${jq}/bin/jq";
  };

  meta.license = lib.licenses.mit;
} ./hook.sh
