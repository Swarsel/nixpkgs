{
  lib,
  fetchFromGitHub,
  aiohttp,
  buildPythonPackage,
  pytest-asyncio,
  pytestCheckHook,
  setuptools,
  typing-extensions,
}:

buildPythonPackage rec {
  pname = "elvia";
  version = "0.1.0";

  src = fetchFromGitHub {
    owner = "andersem";
    repo = "elvia-python";
    tag = "v${version}";
    hash = "sha256-oGXs+EwEIykkq8KjK7qNnZfLj4ZoKlgkldUiJlAI1gA=";
  };

  nativeCheckInputs = [
    pytest-asyncio
    pytestCheckHook
  ];

  build-system = [ setuptools ];

  dependencies = [
    aiohttp
    typing-extensions
  ];

  pyproject = true;
  pythonImportsCheck = [ "elvia" ];

  meta = {
    description = "Unofficial API bindings for Elvia's consumer facing APIs";
    homepage = "https://github.com/andersem/elvia-python";
    changelog = "https://github.com/andersem/elvia-python/releases/tag/${src.tag}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ uvnikita ];
  };
}
