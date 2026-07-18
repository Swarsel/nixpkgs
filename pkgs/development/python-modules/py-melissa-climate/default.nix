{
  lib,
  fetchFromGitHub,
  aiohttp,
  buildPythonPackage,
  pytest-asyncio,
  pytestCheckHook,
  setuptools,
}:

buildPythonPackage rec {
  pname = "py-melissa-climate";
  version = "3.0.3";

  src = fetchFromGitHub {
    owner = "kennedyshead";
    repo = "py-melissa-climate";
    tag = "V${version}";
    hash = "sha256-vKnIFrviCJLMqYUdKKJtqOmD1ZtgtMBMLApG+YiqZdY=";
  };

  nativeCheckInputs = [
    pytest-asyncio
    pytestCheckHook
  ];

  build-system = [ setuptools ];

  dependencies = [
    aiohttp
  ];

  pyproject = true;
  pythonImportsCheck = [ "melissa" ];

  meta = {
    description = "API wrapper for Melissa Climate";
    homepage = "https://github.com/kennedyshead/py-melissa-climate";
    changelog = "https://github.com/kennedyshead/py-melissa-climate/releases/tag/${src.tag}";
    license = lib.licenses.mit;
    maintainers = [ lib.maintainers.jamiemagee ];
  };
}
