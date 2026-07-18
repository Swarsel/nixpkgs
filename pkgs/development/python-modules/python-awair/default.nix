{
  lib,
  fetchFromGitHub,
  aiohttp,
  buildPythonPackage,
  poetry-core,
  pytest-aiohttp,
  pytest-asyncio,
  pytestCheckHook,
  vcrpy,
  voluptuous,
}:

buildPythonPackage rec {
  pname = "python-awair";
  version = "0.2.5";

  src = fetchFromGitHub {
    owner = "ahayworth";
    repo = "python_awair";
    tag = version;
    hash = "sha256-ZET24T6MeCPPL1V84538U6Fb/ZVGv1hwcdTQi3Q+yMY=";
  };

  nativeCheckInputs = [
    pytest-aiohttp
    pytest-asyncio
    pytestCheckHook
    vcrpy
  ];

  build-system = [ poetry-core ];

  dependencies = [
    aiohttp
    voluptuous
  ];

  pyproject = true;
  pythonImportsCheck = [ "python_awair" ];

  meta = {
    description = "Python library for the Awair API";
    homepage = "https://github.com/ahayworth/python_awair";
    changelog = "https://github.com/ahayworth/python_awair/releases/tag/${src.tag}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ fab ];
  };
}
