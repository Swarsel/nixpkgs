{
  lib,
  buildPythonPackage,
  dvc-objects,
  fetchPypi,
  ossfs,
  setuptools,
  setuptools-scm,
}:

buildPythonPackage (finalAttrs: {
  pname = "dvc-oss";
  version = "3.0.0";

  src = fetchPypi {
    inherit (finalAttrs) pname version;
    hash = "sha256-EEf3NAIvzSuW0ysGv24JIc0KZYEPf8HpsPrCmhR7apo=";
  };

  build-system = [
    setuptools
    setuptools-scm
  ];

  dependencies = [
    dvc-objects
    ossfs
  ];

  pyproject = true;
  # Prevent circular dependency
  pythonRemoveDeps = [ "dvc" ];

  # Circular dependency
  # pythonImportsCheck = [ "dvc_ssh" ];
  meta = {
    description = "Alibaba OSS plugin for dvc";
    homepage = "https://pypi.org/project/dvc-oss/";
    changelog = "https://github.com/iterative/dvc-oss/releases/tag/${finalAttrs.version}";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ fab ];
  };
})
