{
  lib,
  buildPythonPackage,
  hatchling,
}:

buildPythonPackage {
  pname = "pytest-cov-stub";
  # please use pythonRemoveDeps rather than change this version
  version = (lib.importTOML ./src/pyproject.toml).project.version;
  src = ./src;
  build-system = [ hatchling ];
  pyproject = true;

  meta = {
    description = "Nixpkgs checkPhase stub for pytest-cov";
    license = lib.licenses.mit;
    maintainers = [ lib.maintainers.pbsds ];
  };
}
