{
  lib,
  buildPythonPackage,
  cramjam,
  fetchPypi,
  setuptools,
  snappy-cpp,
  unittestCheckHook,
}:

buildPythonPackage rec {
  pname = "python-snappy";
  version = "0.7.3";

  src = fetchPypi {
    inherit version;
    hash = "sha256-QCFsG637LTiseB7LFiodDsQPjul0fmELz+/fp5SGzuM=";
    pname = "python_snappy";
  };

  buildInputs = [ snappy-cpp ];
  nativeCheckInputs = [ unittestCheckHook ];

  build-system = [
    cramjam
    setuptools
  ];

  dependencies = [ cramjam ];
  pyproject = true;

  meta = {
    description = "Python library for the snappy compression library from Google";
    homepage = "https://github.com/intake/python-snappy";
    license = lib.licenses.bsd3;
    maintainers = [ ];
  };
}
