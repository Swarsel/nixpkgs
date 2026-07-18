{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  cryptography,
  paho-mqtt,
  requests,
  setuptools,
}:

buildPythonPackage (finalAttrs: {
  pname = "tuya-device-sharing-sdk";
  version = "0.2.13";

  src = fetchFromGitHub {
    owner = "tuya";
    repo = "tuya-device-sharing-sdk";
    tag = finalAttrs.version;
    hash = "sha256-eeAm223Qt9/TYE0BSLJKFdeZY9egq23kIiiYb0F1Rh0=";
  };

  doCheck = false; # no tests
  build-system = [ setuptools ];

  dependencies = [
    cryptography
    paho-mqtt
    requests
  ];

  pyproject = true;
  pythonImportsCheck = [ "tuya_sharing" ];

  meta = {
    description = "Tuya Device Sharing SDK";
    homepage = "https://github.com/tuya/tuya-device-sharing-sdk";
    changelog = "https://github.com/tuya/tuya-device-sharing-sdk/releases/tag/${finalAttrs.version}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ aciceri ];
  };
})
