{
  lib,
  buildPythonPackage,
  fetchPypi,
  pillow,
  requests,
  setuptools,
}:

buildPythonPackage (finalAttrs: {
  pname = "python-resize-image";
  version = "1.1.20";

  src = fetchPypi {
    inherit (finalAttrs) pname version;
    hash = "sha256-sFXauRnWI+zo7JUmLUvb8AbLGhDoGOmzYiHIsYhfmSI=";
  };

  doCheck = false; # sdist missing test artifact
  __structuredAttrs = true;

  build-system = [
    setuptools
  ];

  dependencies = [
    pillow
    requests
  ];

  pyproject = true;

  pythonImportsCheck = [
    "resizeimage"
  ];

  meta = {
    description = "Python package to easily resize images";
    homepage = "https://pypi.org/project/python-resize-image";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ hexa ];
  };
})
