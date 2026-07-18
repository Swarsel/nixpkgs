{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  cbor2,
  pycryptodome,
  setuptools,
  solc-select,
  toml,
}:

buildPythonPackage rec {
  pname = "crytic-compile";
  version = "0.3.11";

  src = fetchFromGitHub {
    owner = "crytic";
    repo = "crytic-compile";
    tag = version;
    hash = "sha256-NVAIVUfh1bizg/HG1z7Ze6o5w6wto744Ogq0LPg0gXg=";
  };

  propagatedBuildInputs = [
    cbor2
    pycryptodome
    setuptools
    solc-select
    toml
  ];

  # required for import check to work
  # PermissionError: [Errno 13] Permission denied: '/homeless-shelter'
  env.HOME = "/tmp";
  # Test require network access
  doCheck = false;
  format = "setuptools";
  pythonImportsCheck = [ "crytic_compile" ];

  meta = {
    description = "Abstraction layer for smart contract build systems";
    homepage = "https://github.com/crytic/crytic-compile";
    changelog = "https://github.com/crytic/crytic-compile/releases/tag/${src.tag}";
    license = lib.licenses.agpl3Plus;

    maintainers = with lib.maintainers; [
      arturcygan
      hellwolf
    ];

    mainProgram = "crytic-compile";
  };
}
