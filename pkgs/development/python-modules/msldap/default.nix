{
  lib,
  asn1crypto,
  asyauth,
  asysocks,
  buildPythonPackage,
  fetchPypi,
  prompt-toolkit,
  setuptools,
  tabulate,
  tqdm,
  unicrypto,
  wcwidth,
  winacl,
}:

buildPythonPackage rec {
  pname = "msldap";
  version = "0.5.15";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-uAJKLAVZFY7EB8tjFyAezINicki6ruzuXf1EGcp3Pj0=";
  };

  # Project doesn't have tests
  doCheck = false;
  build-system = [ setuptools ];

  dependencies = [
    unicrypto
    asyauth
    asysocks
    asn1crypto
    winacl
    prompt-toolkit
    tqdm
    wcwidth
    tabulate
  ];

  pyproject = true;
  pythonImportsCheck = [ "msldap" ];

  meta = {
    description = "Python LDAP library for auditing MS AD";
    homepage = "https://github.com/skelsec/msldap";
    changelog = "https://github.com/skelsec/msldap/releases/tag/${version}";
    license = with lib.licenses; [ mit ];
    maintainers = with lib.maintainers; [ fab ];
  };
}
