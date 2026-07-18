{
  lib,
  addDriverRunpath,
  autoFixElfFiles,
  makeSetupHook,
}:

makeSetupHook {
  propagatedBuildInputs = [
    addDriverRunpath
    autoFixElfFiles
  ];

  name = "auto-add-driver-runpath-hook";
  meta.license = lib.licenses.mit;
} ./auto-add-driver-runpath-hook.sh
