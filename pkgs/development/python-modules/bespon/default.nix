{
  lib,
  buildPythonPackage,
  fetchPypi,
  setuptools,
}:

buildPythonPackage rec {
  pname = "bespon";
  version = "0.7.0";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-dGtXw4uq6pdyXBVfSi9s7kCFUqA1PO7qWEGY0JNAz8Q=";
  };

  nativeBuildInputs = [ setuptools ];
  # upstream doesn't contain tests
  doCheck = false;
  pyproject = true;
  pythonImportsCheck = [ "bespon" ];

  meta = {
    description = "Encodes and decodes data in the BespON format";
    homepage = "https://github.com/gpoore/bespon_py";
    license = lib.licenses.bsd3;
    maintainers = [ ];
  };
}
