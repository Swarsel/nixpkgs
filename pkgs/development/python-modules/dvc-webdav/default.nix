{
  lib,
  buildPythonPackage,
  dvc-objects,
  fetchPypi,
  setuptools,
  setuptools-scm,
  webdav4,
}:

buildPythonPackage (finalAttrs: {
  pname = "dvc-webdav";
  version = "3.0.1";

  src = fetchPypi {
    inherit (finalAttrs) version;
    hash = "sha256-PA0Er7CYWiwVbwtxn0uUN85KzTRmR9j2/uBDtekXx24";
    pname = "dvc_webdav";
  };

  build-system = [
    setuptools
    setuptools-scm
  ];

  dependencies = [
    dvc-objects
    webdav4
  ];

  pyproject = true;
  # Prevent circular dependency
  pythonRemoveDeps = [ "dvc" ];

  # Circular dependency
  # pythonImportsCheck = [ "dvc_webdav" ];
  meta = {
    description = "Webdav plugin for dvc";
    homepage = "https://pypi.org/project/dvc-webdav/";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ fab ];
  };
})
