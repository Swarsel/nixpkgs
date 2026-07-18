{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  # dependencies
  cryptography,
  # build-system
  poetry-core,
  pycryptodomex,
  # tests
  pytestCheckHook,
}:

buildPythonPackage rec {
  pname = "pysnmpcrypto";
  version = "0.1.0";

  src = fetchFromGitHub {
    owner = "lextudio";
    repo = "pysnmpcrypto";
    tag = "v${version}";
    hash = "sha256-gNRD8mSWVVLXwJjb3nT7IKnjTdwTutFDnQybgZTY2b0=";
  };

  nativeCheckInputs = [ pytestCheckHook ];
  build-system = [ poetry-core ];

  dependencies = [
    cryptography
    pycryptodomex
  ];

  pyproject = true;
  pythonImportsCheck = [ "pysnmpcrypto" ];

  meta = {
    description = "Strong crypto support for Python SNMP library";
    homepage = "https://github.com/lextudio/pysnmpcrypto";
    changelog = "https://github.com/lextudio/pysnmpcrypto/blob/v${version}/CHANGES.txt";
    license = lib.licenses.bsd2;
    maintainers = [ ];
  };
}
