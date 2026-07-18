{
  lib,
  fetchFromGitHub,
  aiohttp,
  buildPythonPackage,
  poetry-core,
  pytest-asyncio,
  pytestCheckHook,
}:

buildPythonPackage rec {
  pname = "apsystems-ez1";
  version = "2.7.0";

  src = fetchFromGitHub {
    owner = "SonnenladenGmbH";
    repo = "APsystems-EZ1-API";
    tag = version;
    hash = "sha256-ry3sQPkYnH0asmE41lEQA5G2tk07eTpsBiuJbVIjrXU=";
  };

  nativeCheckInputs = [
    pytestCheckHook
    pytest-asyncio
  ];

  build-system = [ poetry-core ];
  dependencies = [ aiohttp ];
  pyproject = true;
  pythonImportsCheck = [ "APsystemsEZ1" ];

  meta = {
    description = "Streamlined interface for interacting with the local API of APsystems EZ1 Microinverters";
    homepage = "https://github.com/SonnenladenGmbH/APsystems-EZ1-API";
    changelog = "https://github.com/SonnenladenGmbH/APsystems-EZ1-API/releases/tag/${src.tag}";
    license = lib.licenses.mit;
    maintainers = [ ];
  };
}
