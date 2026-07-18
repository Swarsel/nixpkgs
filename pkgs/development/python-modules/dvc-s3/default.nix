{
  lib,
  botocore,
  buildPythonPackage,
  dvc-objects,
  fetchPypi,
  flatten-dict,
  funcy,
  s3fs,
  setuptools,
  setuptools-scm,
}:

buildPythonPackage (finalAttrs: {
  pname = "dvc-s3";
  version = "3.3.0";

  src = fetchPypi {
    inherit (finalAttrs) version;
    hash = "sha256-8dcYpE3O5Rkb60bkSt9LsiiCy46czdjyZAB4q8VkV9Q=";
    pname = "dvc_s3";
  };

  # Network access is needed for tests
  doCheck = false;

  build-system = [
    setuptools
    setuptools-scm
  ];

  dependencies = [
    botocore
    dvc-objects
    flatten-dict
    funcy
    s3fs
  ];

  pyproject = true;
  # Prevent circular dependency
  pythonRemoveDeps = [ "dvc" ];

  # Circular dependency
  # pythonImportsCheck = [
  #   "dvc_s3"
  # ];
  meta = {
    description = "S3 plugin for dvc";
    homepage = "https://pypi.org/project/dvc-s3";
    changelog = "https://github.com/iterative/dvc-s3/releases/tag/${finalAttrs.version}";
    license = lib.licenses.asl20;
    maintainers = [ ];
  };
})
