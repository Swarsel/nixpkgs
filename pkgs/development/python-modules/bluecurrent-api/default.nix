{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  pytest-asyncio,
  pytest-mock,
  pytestCheckHook,
  pytz,
  setuptools,
  websockets,
}:

buildPythonPackage rec {
  pname = "bluecurrent-api";
  version = "1.3.3";

  src = fetchFromGitHub {
    owner = "bluecurrent";
    repo = "HomeAssistantAPI";
    tag = "v${version}";
    hash = "sha256-px4kZOvMUP5aGOQ1uxWnY6w77Woie/hVVdyylW8uSX4=";
  };

  nativeCheckInputs = [
    pytest-asyncio
    pytest-mock
    pytestCheckHook
  ];

  build-system = [ setuptools ];

  dependencies = [
    pytz
    websockets
  ];

  pyproject = true;
  pythonImportsCheck = [ "bluecurrent_api" ];
  pythonRelaxDeps = [ "websockets" ];

  meta = {
    description = "Wrapper for the Blue Current websocket api";
    homepage = "https://github.com/bluecurrent/HomeAssistantAPI";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ dotlambda ];
  };
}
