{
  lib,
  fetchFromGitHub,
  aiohttp,
  buildPythonPackage,
  hatchling,
  pytestCheckHook,
  requests,
}:

buildPythonPackage rec {
  pname = "iottycloud";
  version = "0.3.0";

  src = fetchFromGitHub {
    owner = "pburgio";
    repo = "iottyCloud";
    tag = version;
    hash = "sha256-tsCa87BdwKumsv5N0lAPZmMIfm2W6Pw0LS3sF9c/oRA=";
  };

  nativeCheckInputs = [
    pytestCheckHook
    requests
  ];

  build-system = [ hatchling ];
  dependencies = [ aiohttp ];
  pyproject = true;
  pythonImportsCheck = [ "iottycloud" ];

  meta = {
    description = "Python library to interact with iotty CloudApi";
    homepage = "https://github.com/pburgio/iottyCloud";
    changelog = "https://github.com/pburgio/iottyCloud/releases/tag/${version}";
    license = lib.licenses.agpl3Only;
    maintainers = with lib.maintainers; [ dotlambda ];
  };
}
