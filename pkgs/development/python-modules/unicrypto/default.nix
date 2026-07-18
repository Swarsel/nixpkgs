{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  pycryptodome,
  pycryptodomex,
  setuptools,
}:

buildPythonPackage rec {
  pname = "unicrypto";
  version = "0.0.12";

  src = fetchFromGitHub {
    owner = "skelsec";
    repo = "unicrypto";
    tag = version;
    hash = "sha256-RYwovFMalBNDPDEVjQ/8/N7DkOMiyeEQ5ESdgCK8RW8=";
  };

  # Module has no tests
  doCheck = false;
  build-system = [ setuptools ];

  dependencies = [
    pycryptodome
    pycryptodomex
  ];

  pyproject = true;
  pythonImportsCheck = [ "unicrypto" ];

  meta = {
    description = "Unified interface for cryptographic libraries";
    homepage = "https://github.com/skelsec/unicrypto";
    changelog = "https://github.com/skelsec/unicrypto/releases/tag/${src.tag}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ fab ];
  };
}
