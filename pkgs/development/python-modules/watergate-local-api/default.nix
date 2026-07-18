{
  lib,
  fetchFromGitHub,
  aiohttp,
  aioresponses,
  buildPythonPackage,
  pytest-asyncio,
  pytestCheckHook,
  setuptools,
}:

buildPythonPackage rec {
  pname = "watergate-local-api";
  version = "2025.1.0";

  src = fetchFromGitHub {
    owner = "watergate-ai";
    repo = "watergate-local-api-python";
    tag = version;
    hash = "sha256-px1vtWGW9JlU9ZXvmTq9YXZDmWIU0xYy3KOyamGyY74=";
  };

  nativeCheckInputs = [
    aioresponses
    pytest-asyncio
    pytestCheckHook
  ];

  build-system = [ setuptools ];

  dependencies = [
    aiohttp
  ];

  pyproject = true;
  pythonImportsCheck = [ "watergate_local_api" ];

  meta = {
    description = "Python package to interact with the Watergate Local API";
    homepage = "https://github.com/watergate-ai/watergate-local-api-python";
    changelog = "https://github.com/watergate-ai/watergate-local-api-python/releases/tag/${src.tag}";
    license = lib.licenses.gpl3Only;
    maintainers = with lib.maintainers; [ dotlambda ];
  };
}
