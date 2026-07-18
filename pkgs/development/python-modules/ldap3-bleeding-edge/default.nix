{
  lib,
  buildPythonPackage,
  cryptography,
  fetchPypi,
  gssapi,
  pyasn1,
  pycryptodomex,
  setuptools,
}:

buildPythonPackage rec {
  pname = "ldap3-bleeding-edge";
  version = "2.10.1.1338";

  src = fetchPypi {
    inherit version;
    hash = "sha256-7j5W1C0scvjm6j3eueNomdTRd+Uzishhr2U1bb1gB3s=";
    pname = "ldap3_bleeding_edge";
  };

  # Tests require network access
  doCheck = false;
  build-system = [ setuptools ];

  dependencies = [
    cryptography
    pyasn1
    pycryptodomex
  ];

  optional-dependencies = {
    kerberos = [ gssapi ];
  };

  pyproject = true;
  pythonImportsCheck = [ "ldap3" ];

  meta = {
    description = "Strictly RFC 4510 conforming LDAP V3 client library (bleeding edge)";
    homepage = "https://pypi.org/project/ldap3-bleeding-edge/";
    license = lib.licenses.gpl3Only;
    maintainers = with lib.maintainers; [ fab ];
  };
}
