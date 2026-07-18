{
  lib,
  fetchFromGitHub,
  aiohttp,
  aioresponses,
  buildPythonPackage,
  poetry-core,
  pytest-asyncio,
  pytest-cov-stub,
  pytestCheckHook,
  yarl,
}:

buildPythonPackage rec {
  pname = "aiosolaredge";
  version = "1.0.2";

  src = fetchFromGitHub {
    owner = "bdraco";
    repo = "aiosolaredge";
    tag = "v${version}";
    hash = "sha256-1RdkYcdhhU+MaP91iJ1tSrL0OlUi6Il1XBXnmRYhC7g=";
  };

  nativeCheckInputs = [
    aioresponses
    pytest-asyncio
    pytest-cov-stub
    pytestCheckHook
  ];

  build-system = [ poetry-core ];

  dependencies = [
    aiohttp
    yarl
  ];

  pyproject = true;
  pythonImportsCheck = [ "aiosolaredge" ];

  meta = {
    description = "Asyncio SolarEdge API client";
    homepage = "https://github.com/bdraco/aiosolaredge";
    changelog = "https://github.com/bdraco/aiosolaredge/blob/${src.tag}/CHANGELOG.md";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ dotlambda ];
  };
}
