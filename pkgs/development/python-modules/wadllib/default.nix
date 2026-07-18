{
  lib,
  buildPythonPackage,
  fetchPypi,
  lazr-uri,
  setuptools,
}:

buildPythonPackage (finalAttrs: {
  pname = "wadllib";
  version = "2.1.0";

  src = fetchPypi {
    inherit (finalAttrs) pname version;
    hash = "sha256-acYKGIycYpoOlH36/Yms3It9jUBKa16wrSWP7yk2JQE=";
  };

  # pypi tarball has no tests
  doCheck = false;
  build-system = [ setuptools ];

  dependencies = [
    lazr-uri
  ];

  pyproject = true;
  pythonImportsCheck = [ "wadllib" ];

  meta = {
    description = "Navigate HTTP resources using WADL files as guides";
    homepage = "https://launchpad.net/wadllib";
    license = lib.licenses.lgpl3Only;
    maintainers = [ ];
  };
})
