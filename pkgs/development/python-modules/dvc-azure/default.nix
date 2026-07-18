{
  lib,
  adlfs,
  azure-identity,
  buildPythonPackage,
  dvc-objects,
  fetchPypi,
  knack,
  setuptools,
  setuptools-scm,
}:

buildPythonPackage (finalAttrs: {
  pname = "dvc-azure";
  version = "3.1.0";

  src = fetchPypi {
    inherit (finalAttrs) pname version;
    hash = "sha256-UsvHDVQUtQIZs9sKFvaK0l2rp24/Igrr5OSbPGSYriA=";
  };

  # Network access is needed for tests
  doCheck = false;

  build-system = [
    setuptools
    setuptools-scm
  ];

  dependencies = [
    adlfs
    azure-identity
    dvc-objects
    knack
  ];

  pyproject = true;
  # Prevent circular dependency
  pythonRemoveDeps = [ "dvc" ];

  # Circular dependency
  # pythonImportsCheck = [
  #   "dvc_azure"
  # ];
  meta = {
    description = "Azure plugin for dvc";
    homepage = "https://pypi.org/project/dvc-azure/";
    changelog = "https://github.com/iterative/dvc-azure/releases/tag/${finalAttrs.version}";
    license = lib.licenses.asl20;
    maintainers = [ ];
  };
})
