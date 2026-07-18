{
  buildPythonPackage,
  certbot,
  cryptography,
  josepy,
  pyopenssl,
  pyrfc3339,
  requests,
  setuptools,
}:

buildPythonPackage rec {
  inherit (certbot) version src;
  pname = "acme";
  # does not contain any tests
  doCheck = false;

  build-system = [
    setuptools
  ];

  dependencies = [
    cryptography
    pyopenssl
    pyrfc3339
    requests
    josepy
  ];

  pyproject = true;
  pythonImportsCheck = [ "acme" ];
  sourceRoot = "${src.name}/acme";

  meta = certbot.meta // {
    description = "ACME protocol implementation in Python";
  };
}
