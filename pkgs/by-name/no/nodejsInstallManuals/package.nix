{
  lib,
  installShellFiles,
  jq,
  makeSetupHook,
}:

makeSetupHook {
  propagatedBuildInputs = [ installShellFiles ];
  name = "nodejs-install-manuals";

  substitutions = {
    jq = "${jq}/bin/jq";
  };

  meta.license = lib.licenses.mit;
} ./hook.sh
