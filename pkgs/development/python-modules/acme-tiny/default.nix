{
  lib,
  buildPythonPackage,
  fetchPypi,
  fuse,
  fusepy,
  openssl,
  setuptools,
  setuptools-scm,
}:

buildPythonPackage rec {
  pname = "acme-tiny";
  version = "5.0.3";

  src = fetchPypi {
    inherit version;
    hash = "sha256-LV64B+JZhq69qbBJ2dFG8YW6/q1u+x6MxB1rQrm8pjw=";
    pname = "acme_tiny";
  };

  nativeCheckInputs = [
    fusepy
    fuse
  ];

  build-system = [
    setuptools
    setuptools-scm
  ];

  patchPhase = ''
    substituteInPlace acme_tiny.py --replace-fail '"openssl"' '"${openssl.bin}/bin/openssl"'
    substituteInPlace tests/test_module.py --replace-fail '"openssl"' '"${openssl.bin}/bin/openssl"'
    substituteInPlace tests/utils.py --replace-fail /etc/ssl/openssl.cnf ${openssl.out}/etc/ssl/openssl.cnf
  '';

  pyproject = true;
  pythonImportsCheck = [ "acme_tiny" ];

  meta = {
    description = "Tiny script to issue and renew TLS certs from Let's Encrypt";
    homepage = "https://github.com/diafygi/acme-tiny";
    license = lib.licenses.mit;
    mainProgram = "acme-tiny";
  };
}
