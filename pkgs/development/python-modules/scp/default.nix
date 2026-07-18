{
  lib,
  buildPythonPackage,
  fetchPypi,
  paramiko,
  python,
}:

buildPythonPackage rec {
  pname = "scp";
  version = "0.15.0";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-8bIumTISPM8X7r8Z4JU8bpFI9Yn5PZG4cpQaaWMFyD8=";
  };

  propagatedBuildInputs = [ paramiko ];
  #The Pypi package doesn't include the test
  doCheck = false;

  checkPhase = ''
    SCPPY_PORT=10022 ${python.interpreter} test.py
  '';

  format = "setuptools";
  pythonImportsCheck = [ "scp" ];

  meta = {
    description = "SCP module for paramiko";
    homepage = "https://github.com/jbardin/scp.py";
    license = lib.licenses.lgpl21Only;
    maintainers = with lib.maintainers; [ xnaveira ];
  };
}
