{
  lib,
  asn1crypto,
  buildPythonPackage,
  cryptography,
  fetchPypi,
  h11,
  setuptools,
}:

buildPythonPackage rec {
  pname = "asysocks";
  version = "0.2.18";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-zGGW6CyK3Is84jId3fY1UAx2AxbaS3zKMhtTLLs9/fU=";
  };

  # Upstream hasn't release the tests yet
  doCheck = false;
  build-system = [ setuptools ];

  dependencies = [
    asn1crypto
    cryptography
    h11
  ];

  pyproject = true;
  pythonImportsCheck = [ "asysocks" ];

  meta = {
    description = "Python Socks4/5 client and server library";
    homepage = "https://github.com/skelsec/asysocks";
    changelog = "https://github.com/skelsec/asysocks/releases/tag/${version}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ fab ];
  };
}
