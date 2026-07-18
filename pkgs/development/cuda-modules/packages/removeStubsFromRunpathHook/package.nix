{
  lib,
  addDriverRunpath,
  arrayUtilities,
  autoFixElfFiles,
  makeSetupHook,
}:
makeSetupHook {
  propagatedBuildInputs = [
    arrayUtilities.getRunpathEntries
    autoFixElfFiles
  ];

  name = "removeStubsFromRunpathHook";

  substitutions = {
    driverLinkLib = addDriverRunpath.driverLink + "/lib";
  };

  meta.license = lib.licenses.mit;
} ./removeStubsFromRunpathHook.bash
