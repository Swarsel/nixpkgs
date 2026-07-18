{
  lib,
  asn1crypto,
  asysocks,
  buildPythonPackage,
  fetchPypi,
  minikerberos,
  setuptools,
  unicrypto,
}:

buildPythonPackage rec {
  pname = "asyauth";
  version = "0.0.23";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-NvA4TdsrYloQMzNjyv4ZDW6cntF/0Hs+KIdkGjzGJvA=";
  };

  # Project doesn't have tests
  doCheck = false;
  build-system = [ setuptools ];

  dependencies = [
    asn1crypto
    asysocks
    minikerberos
    unicrypto
  ];

  pyproject = true;
  pythonImportsCheck = [ "asyauth" ];

  meta = {
    description = "Unified authentication library";
    homepage = "https://github.com/skelsec/asyauth";
    changelog = "https://github.com/skelsec/asyauth/releases/tag/${version}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ fab ];
  };
}
