{
  lib,
  fetchFromGitHub,
  aiohttp,
  attrs,
  buildPythonPackage,
  pythonOlder,
  setuptools,
  voluptuous,
}:

buildPythonPackage rec {
  pname = "hatasmota";
  version = "0.10.1";

  src = fetchFromGitHub {
    owner = "emontnemery";
    repo = "hatasmota";
    tag = version;
    hash = "sha256-Be6W7+DMpMXezEQDkEN9+ei7cJXP1bGIURuXlMNyR0Y=";
  };

  # Project has no tests
  doCheck = false;
  build-system = [ setuptools ];

  dependencies = [
    aiohttp
    attrs
    voluptuous
  ];

  disabled = pythonOlder "3.13";
  pyproject = true;
  pythonImportsCheck = [ "hatasmota" ];

  meta = {
    description = "Python module to help parse and construct Tasmota MQTT messages";
    homepage = "https://github.com/emontnemery/hatasmota";
    changelog = "https://github.com/emontnemery/hatasmota/releases/tag/${src.tag}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ fab ];
  };
}
