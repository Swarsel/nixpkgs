{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  packaging,
  pycryptodome,
  requests,
  setuptools,
}:

buildPythonPackage rec {
  pname = "solc-select";
  version = "1.2.0";

  src = fetchFromGitHub {
    owner = "crytic";
    repo = "solc-select";
    tag = "v.${version}";
    hash = "sha256-pPDiP8GNE/KAFS4Jm6jLpKozktxy70+f00QFUa4wMiQ=";
  };

  # no tests
  doCheck = false;
  build-system = [ setuptools ];

  dependencies = [
    packaging
    pycryptodome
    requests
  ];

  pyproject = true;
  pythonImportsCheck = [ "solc_select" ];

  meta = {
    description = "Manage and switch between Solidity compiler versions";
    homepage = "https://github.com/crytic/solc-select";
    license = lib.licenses.agpl3Plus;
    maintainers = with lib.maintainers; [ arturcygan ];
  };
}
