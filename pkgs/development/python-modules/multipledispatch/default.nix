{
  lib,
  buildPythonPackage,
  fetchPypi,
  six,
}:

buildPythonPackage rec {
  pname = "multipledispatch";
  version = "1.0.0";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-XIOZFUZcaCBsPpxHM1eQghbCg4O0JTYeXRRFlL+Fp+A=";
  };

  propagatedBuildInputs = [ six ];
  # No tests in archive
  doCheck = false;
  format = "setuptools";

  meta = {
    description = "Relatively sane approach to multiple dispatch in Python";
    homepage = "https://github.com/mrocklin/multipledispatch/";
    license = lib.licenses.bsd3;
  };
}
