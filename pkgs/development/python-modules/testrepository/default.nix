{
  lib,
  buildPythonPackage,
  fetchPypi,
  fixtures,
  pbr,
  python,
  python-subunit,
  testresources,
  testtools,
}:

buildPythonPackage rec {
  pname = "testrepository";
  version = "0.0.21";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-Nor89+CQs8aIvddUol9kvDFOUSuBb4xxufn8F9w3o9k=";
  };

  buildInputs = [ pbr ];

  propagatedBuildInputs = [
    fixtures
    python-subunit
    testtools
  ];

  nativeCheckInputs = [ testresources ];

  checkPhase = ''
    ${python.interpreter} ./testr
  '';

  format = "setuptools";

  meta = {
    description = "Database of test results which can be used as part of developer workflow";
    homepage = "https://pypi.org/project/testrepository/";
    license = lib.licenses.bsd2;
    mainProgram = "testr";
  };
}
