{
  lib,
  fetchFromGitHub,
  asn1crypto,
  buildPythonPackage,
  cython,
  setuptools-scm,
}:

buildPythonPackage rec {
  pname = "python-pkcs11";
  version = "0.9.3";

  src = fetchFromGitHub {
    owner = "danni";
    repo = "python-pkcs11";
    tag = "v${version}";
    sha256 = "sha256-ursQHwyTUz4kCg66+Rnvo8bI3fzA3k9FsmbnUvpq/aY=";
  };

  # Test require additional setup
  doCheck = false;

  build-system = [
    cython
    setuptools-scm
  ];

  dependencies = [
    asn1crypto
  ];

  pyproject = true;
  pythonImportsCheck = [ "pkcs11" ];

  meta = {
    description = "PKCS#11/Cryptoki support for Python";
    homepage = "https://github.com/danni/python-pkcs11";
    changelog = "https://github.com/pyauth/python-pkcs11/releases/tag/${src.tag}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ fab ];
  };
}
