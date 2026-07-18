{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  certifi,
  circuitbreaker,
  cryptography,
  pyopenssl,
  python-dateutil,
  pytz,
  setuptools,
}:

buildPythonPackage rec {
  pname = "oci";
  version = "2.165.1";

  src = fetchFromGitHub {
    owner = "oracle";
    repo = "oci-python-sdk";
    tag = "v${version}";
    hash = "sha256-pF3+0Hogk4FmPOp20ROVb3304+mGs0iUYeiNkszCGPY=";
  };

  # Tests fail: https://github.com/oracle/oci-python-sdk/issues/164
  doCheck = false;
  build-system = [ setuptools ];

  dependencies = [
    certifi
    circuitbreaker
    cryptography
    pyopenssl
    python-dateutil
    pytz
  ];

  pyproject = true;
  pythonImportsCheck = [ "oci" ];

  pythonRelaxDeps = [
    "cryptography"
    "pyOpenSSL"
  ];

  meta = {
    description = "Oracle Cloud Infrastructure Python SDK";
    homepage = "https://github.com/oracle/oci-python-sdk";
    changelog = "https://github.com/oracle/oci-python-sdk/blob/${src.tag}/CHANGELOG.rst";

    license = with lib.licenses; [
      asl20 # or
      upl
    ];

    maintainers = with lib.maintainers; [
      ilian
    ];
  };
}
