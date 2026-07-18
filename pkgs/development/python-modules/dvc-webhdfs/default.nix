{
  lib,
  buildPythonPackage,
  dvc-objects,
  fetchPypi,
  fsspec,
  requests-kerberos,
  setuptools,
  setuptools-scm,
}:

buildPythonPackage (finalAttrs: {
  pname = "dvc-webhdfs";
  version = "3.1.0";

  src = fetchPypi {
    inherit (finalAttrs) pname version;
    hash = "sha256-bolIQ9Fc52agXGFt7anZvDYSSOk7+eozi5lublHqD+o=";
  };

  build-system = [
    setuptools
    setuptools-scm
  ];

  dependencies = [
    dvc-objects
    fsspec
  ];

  optional-dependencies = {
    kerberos = [ requests-kerberos ];
  };

  pyproject = true;
  # Prevent circular dependency
  pythonRemoveDeps = [ "dvc" ];

  # Circular dependency
  # pythonImportsCheck = [ "dvc_webhdfs" ];
  meta = {
    description = "Webhdfs plugin for dvc";
    homepage = "https://pypi.org/project/dvc-webhdfs/";
    changelog = "https://github.com/iterative/dvc-webhdfs/releases/tag/${finalAttrs.version}";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ fab ];
  };
})
