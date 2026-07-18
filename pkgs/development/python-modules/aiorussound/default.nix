{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  # dependencies
  mashumaro,
  orjson,
  # build-system
  poetry-core,
  # tests
  pytestCheckHook,
  pythonOlder,
  serialx,
}:

buildPythonPackage rec {
  pname = "aiorussound";
  version = "5.0.1";

  src = fetchFromGitHub {
    owner = "noahhusby";
    repo = "aiorussound";
    tag = version;
    hash = "sha256-TFRxeQQwgoI4O0k6A1pO622oEONOxANQDLr7SAkjuA0=";
  };

  nativeCheckInputs = [
    pytestCheckHook
  ];

  build-system = [ poetry-core ];

  dependencies = [
    mashumaro
    orjson
    serialx
  ];

  # requires newer f-strings introduced in 3.12
  disabled = pythonOlder "3.12";
  pyproject = true;
  pythonImportsCheck = [ "aiorussound" ];

  meta = {
    description = "Async python package for interfacing with Russound RIO hardware";
    homepage = "https://github.com/noahhusby/aiorussound";
    changelog = "https://github.com/noahhusby/aiorussound/releases/tag/${src.tag}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ hexa ];
  };
}
