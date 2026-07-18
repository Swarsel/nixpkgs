{
  lib,
  fetchFromGitHub,
  aiowinreg,
  buildPythonPackage,
  colorama,
  pycryptodomex,
  setuptools,
  tqdm,
  unicrypto,
}:

buildPythonPackage rec {
  pname = "aesedb";
  version = "0.1.8";

  src = fetchFromGitHub {
    owner = "skelsec";
    repo = "aesedb";
    tag = version;
    hash = "sha256-YoeqxYkohAR6RaQYDXt7T00LCQDSb/o/ddxYRDGP/2s=";
  };

  nativeBuildInputs = [ setuptools ];

  propagatedBuildInputs = [
    aiowinreg
    colorama
    pycryptodomex
    tqdm
    unicrypto
  ];

  # Module has no tests
  doCheck = false;
  pyproject = true;
  pythonImportsCheck = [ "aesedb" ];

  meta = {
    description = "Parser for JET databases";
    homepage = "https://github.com/skelsec/aesedb";
    changelog = "https://github.com/skelsec/aesedb/releases/tag/${version}";
    license = with lib.licenses; [ mit ];
    maintainers = with lib.maintainers; [ fab ];
    mainProgram = "antdsparse";
  };
}
