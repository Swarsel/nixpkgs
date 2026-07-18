{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  pycryptodomex,
  pynacl,
  pysocks,
  pytest-cov-stub,
  pytestCheckHook,
  requests,
  responses,
  six,
  varint,
}:

buildPythonPackage rec {
  pname = "monero";
  version = "1.1.1";

  src = fetchFromGitHub {
    owner = "monero-ecosystem";
    repo = "monero-python";
    rev = "v${version}";
    hash = "sha256-WIF3pFBOLgozYTrQHLzIRgSlT3dTZTe+7sF/dVjVdTo=";
  };

  propagatedBuildInputs = [
    pycryptodomex
    pynacl
    pysocks
    requests
    six
    varint
  ];

  nativeCheckInputs = [
    pytestCheckHook
    pytest-cov-stub
    responses
  ];

  format = "setuptools";
  pythonImportsCheck = [ "monero" ];
  pythonRelaxDeps = [ "pynacl" ];
  pythonRemoveDeps = [ "ipaddress" ];

  meta = {
    description = "Comprehensive Python module for handling Monero";
    homepage = "https://github.com/monero-ecosystem/monero-python";
    license = lib.licenses.bsd3;
    maintainers = with lib.maintainers; [ prusnak ];
  };
}
