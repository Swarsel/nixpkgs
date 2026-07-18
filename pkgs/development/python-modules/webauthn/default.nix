{
  lib,
  fetchFromGitHub,
  asn1crypto,
  buildPythonPackage,
  cbor2,
  cryptography,
  pyopenssl,
  pytestCheckHook,
  setuptools,
}:

buildPythonPackage rec {
  pname = "webauthn";
  version = "2.7.0";

  src = fetchFromGitHub {
    owner = "duo-labs";
    repo = "py_webauthn";
    tag = "v${version}";
    hash = "sha256-aZDptKJPFU6Oo4vKkIWkqkJ5ogDe5x3v7PAQRixWFe4=";
  };

  propagatedBuildInputs = [
    asn1crypto
    cbor2
    cryptography
    pyopenssl
  ];

  nativeCheckInputs = [ pytestCheckHook ];
  build-system = [ setuptools ];
  pyproject = true;
  pythonImportsCheck = [ "webauthn" ];

  meta = {
    description = "Implementation of the WebAuthn API";
    homepage = "https://github.com/duo-labs/py_webauthn";
    changelog = "https://github.com/duo-labs/py_webauthn/blob/${src.tag}/CHANGELOG.md";
    license = lib.licenses.bsd3;
    maintainers = [ ];
  };
}
