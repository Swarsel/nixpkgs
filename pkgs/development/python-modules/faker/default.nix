{
  lib,
  buildPythonPackage,
  fetchPypi,
  freezegun,
  pillow,
  pytestCheckHook,
  python-dateutil,
  setuptools,
  typing-extensions,
  tzdata,
  ukpostcodeparser,
  validators,
}:

buildPythonPackage rec {
  pname = "faker";
  version = "40.1.2";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-t2poFjql8XHSYPwkgnqDSbwdtnL2pmU1no0AlegTXTA=";
  };

  nativeCheckInputs = [
    freezegun
    pillow
    pytestCheckHook
    ukpostcodeparser
    validators
  ];

  build-system = [ setuptools ];

  dependencies = [
    python-dateutil
    typing-extensions
    tzdata
  ];

  # avoid tests which import random2, an abandoned library
  disabledTestPaths = [ "tests/providers/test_ssn.py" ];
  pyproject = true;
  pythonImportsCheck = [ "faker" ];

  meta = {
    description = "Python library for generating fake user data";
    homepage = "http://faker.rtfd.org";
    license = lib.licenses.mit;
    maintainers = [ ];
    mainProgram = "faker";
  };
}
