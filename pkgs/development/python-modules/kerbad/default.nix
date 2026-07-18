{
  lib,
  fetchFromGitHub,
  # dependencies
  asn1crypto,
  asysocks,
  buildPythonPackage,
  cryptography,
  dnspython,
  minikerberos,
  oscrypto,
  # build-system
  setuptools,
  six,
  tqdm,
  unicrypto,
}:

buildPythonPackage {
  pname = "kerbad";
  version = "0.5.6-unstable-2025-10-07";

  src = fetchFromGitHub {
    owner = "CravateRouge";
    repo = "kerbad";
    rev = "3c2284de4d2390e22026b550705622ed39e5c05a"; # no tag available
    hash = "sha256-V4KaF6lsECoLVpGZTZ4p7q9drHSsrsLPI/9zEQpqm3I=";
  };

  # Module has no tests
  doCheck = false;
  build-system = [ setuptools ];

  dependencies = [
    asn1crypto
    asysocks
    cryptography
    dnspython
    minikerberos
    oscrypto
    six
    tqdm
    unicrypto
  ];

  pyproject = true;
  pythonImportsCheck = [ "minikerberos" ];

  meta = {
    description = "Kerberos manipulation library in pure Python";
    homepage = "https://github.com/CravateRouge/kerbad";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ fab ];
  };
}
