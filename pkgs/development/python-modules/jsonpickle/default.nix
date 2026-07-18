{
  lib,
  buildPythonPackage,
  fetchPypi,
  # tests
  pytestCheckHook,
  pythonAtLeast,
  # build-system
  setuptools,
  setuptools-scm,
  simplejson,
}:

buildPythonPackage rec {
  pname = "jsonpickle";
  version = "4.1.1";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-+G4Y8T4rlsHB7t4Le5AJW7th2Z/twUgTxE3C82HbuuE=";
  };

  nativeCheckInputs = [
    pytestCheckHook
    simplejson
  ];

  preCheck = ''
    rm pytest.ini
  '';

  build-system = [
    setuptools
    setuptools-scm
  ];

  disabledTests = lib.optionals (pythonAtLeast "3.12") [
    # imports distutils
    "test_thing_with_submodule"
  ];

  pyproject = true;

  meta = {
    description = "Python library for serializing any arbitrary object graph into JSON";
    homepage = "http://jsonpickle.github.io/";
    license = lib.licenses.bsd3;
    downloadPage = "https://github.com/jsonpickle/jsonpickle";
  };
}
