{
  lib,
  buildPythonPackage,
  fetchPypi,
  flexmock,
  pytest-cov-stub,
  pytestCheckHook,
  six,
}:

buildPythonPackage rec {
  pname = "iocapture";
  version = "0.1.2";

  src = fetchPypi {
    inherit pname version;
    sha256 = "86670e1808bcdcd4f70112f43da72ae766f04cd8311d1071ce6e0e0a72e37ee8";
  };

  # No tests in archive
  doCheck = false;

  nativeCheckInputs = [
    flexmock
    pytestCheckHook
    pytest-cov-stub
    six
  ];

  format = "setuptools";

  meta = {
    description = "Capture stdout, stderr easily";
    homepage = "https://github.com/oinume/iocapture";
    license = lib.licenses.mit;
  };
}
