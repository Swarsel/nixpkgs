{
  lib,
  buildPythonPackage,
  crcmod,
  cryptography,
  fetchPypi,
  fido2,
  hidapi,
  poetry-core,
  protobuf,
  pyserial,
  requests,
  semver,
  tlv8,
}:

buildPythonPackage rec {
  pname = "nitrokey";
  version = "0.4.2";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-ZyB5gNZc5HxohZypc/198PPBxqG9URscQfXYAWzs7n8=";
  };

  # no tests
  doCheck = false;
  build-system = [ poetry-core ];

  dependencies = [
    fido2
    requests
    semver
    tlv8
    crcmod
    cryptography
    hidapi
    protobuf
    pyserial
  ];

  pyproject = true;
  pythonImportsCheck = [ "nitrokey" ];

  pythonRelaxDeps = [
    "protobuf"
    "hidapi"
  ];

  meta = {
    description = "Python SDK for Nitrokey devices";
    homepage = "https://github.com/Nitrokey/nitrokey-sdk-py";
    changelog = "https://github.com/Nitrokey/nitrokey-sdk-py/releases/tag/v${version}";

    license = with lib.licenses; [
      asl20
      mit
    ];

    maintainers = with lib.maintainers; [ panicgh ];
  };
}
