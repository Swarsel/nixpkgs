{
  lib,
  buildPythonPackage,
  fetchPypi,
  mock,
  six,
  sphinx,
  unittestCheckHook,
}:

buildPythonPackage rec {
  pname = "sphinx-testing";
  version = "1.0.1";

  src = fetchPypi {
    inherit pname version;
    sha256 = "ef661775b5722d7b00f67fc229104317d35637a4fb4434bf2c005afdf1da4d09";
  };

  propagatedBuildInputs = [
    sphinx
    six
  ];

  # Test failures https://github.com/sphinx-doc/sphinx-testing/issues/5
  doCheck = false;

  nativeCheckInputs = [
    unittestCheckHook
    mock
  ];

  format = "setuptools";

  unittestFlagsArray = [
    "-s"
    "tests"
  ];

  meta = {
    description = "Testing utility classes and functions for Sphinx extensions";
    homepage = "https://github.com/sphinx-doc/sphinx-testing";
    license = lib.licenses.bsd2;
  };
}
