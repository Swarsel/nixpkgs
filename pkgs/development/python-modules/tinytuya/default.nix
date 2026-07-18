{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  colorama,
  cryptography,
  requests,
  setuptools,
}:

buildPythonPackage rec {
  pname = "tinytuya";
  version = "1.20.0";

  src = fetchFromGitHub {
    owner = "jasonacox";
    repo = "tinytuya";
    tag = "v${version}";
    hash = "sha256-kyLRTfhTB8olZ48rUm+WtnuGZmCojnlUY4CeF+FADWg=";
  };

  # Tests require real network resources
  doCheck = false;
  build-system = [ setuptools ];

  dependencies = [
    cryptography
    requests
    colorama
  ];

  pyproject = true;
  pythonImportsCheck = [ "tinytuya" ];

  meta = {
    description = "Python API for Tuya WiFi smart devices using a direct local area network (LAN) connection or the cloud (TuyaCloud API)";
    homepage = "https://github.com/jasonacox/tinytuya";
    changelog = "https://github.com/jasonacox/tinytuya/releases/tag/${src.tag}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ pathob ];
  };
}
