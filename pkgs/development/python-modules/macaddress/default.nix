{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  hypothesis,
  pytestCheckHook,
  reprshed,
}:

buildPythonPackage rec {
  pname = "macaddress";
  version = "2.0.2";

  src = fetchFromGitHub {
    owner = "mentalisttraceur";
    repo = "python-macaddress";
    rev = "v${version}";
    hash = "sha256-2eD5Ui8kUduKLJ0mSiwaz7TQSeF1+2ASirp70V/8+EA=";
  };

  nativeCheckInputs = [
    pytestCheckHook
    hypothesis
    reprshed
  ];

  enabledTestPaths = [ "test.py" ];
  format = "setuptools";
  pythonImportsCheck = [ "macaddress" ];

  meta = {
    description = "Module for handling hardware identifiers like MAC addresses";
    homepage = "https://github.com/mentalisttraceur/python-macaddress";
    license = lib.licenses.bsd0;
    maintainers = with lib.maintainers; [ netali ];
  };
}
