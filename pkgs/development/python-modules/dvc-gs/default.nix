{
  lib,
  buildPythonPackage,
  dvc-objects,
  fetchPypi,
  gcsfs,
  setuptools-scm,
}:

buildPythonPackage (finalAttrs: {
  pname = "dvc-gs";
  version = "3.1.0";

  src = fetchPypi {
    inherit (finalAttrs) version;
    hash = "sha256-QhhWD/HVGW/Qx5FiZVzXnFE0+mHr40o6UH+vB0kibu4=";
    pname = "dvc_gs";
  };

  # Network access is needed for tests
  doCheck = false;
  build-system = [ setuptools-scm ];

  dependencies = [
    gcsfs
    dvc-objects
  ];

  pyproject = true;
  # Prevent circular dependency
  pythonRemoveDeps = [ "dvc" ];

  # Circular dependency
  # pythonImportsCheck = [
  #   "dvc_gs"
  # ];
  meta = {
    description = "gs plugin for dvc";
    homepage = "https://pypi.org/project/dvc-gs/version";
    changelog = "https://github.com/iterative/dvc-gs/releases/tag/${finalAttrs.version}";
    license = lib.licenses.asl20;
    maintainers = [ ];
  };
})
