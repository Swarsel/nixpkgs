{
  lib,
  buildPythonPackage,
  fetchPypi,
  setuptools,
}:

buildPythonPackage (finalAttrs: {
  pname = "easydict";
  version = "1.13";

  src = fetchPypi {
    inherit (finalAttrs) pname version;
    hash = "sha256-sRNd7bxByAEOK8H3fsl0TH+qQrzhoch0FnkUSdbId4A=";
  };

  doCheck = false; # No tests in archive
  __structuredAttrs = true;

  build-system = [
    setuptools
  ];

  pyproject = true;
  pythonImportsCheck = [ "easydict" ];

  meta = {
    description = "Access dict values as attributes (works recursively)";
    homepage = "https://github.com/makinacorpus/easydict";
    changelog = "https://github.com/makinacorpus/easydict/releases/tag/${finalAttrs.version}";
    license = lib.licenses.lgpl3;
  };
})
