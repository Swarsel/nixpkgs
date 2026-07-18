{
  lib,
  fetchFromGitHub,
  aiohttp,
  buildPythonPackage,
  pydantic,
  pytest-asyncio,
  pytestCheckHook,
  setuptools,
}:

buildPythonPackage rec {
  pname = "pytouchlinesl";
  version = "0.6.0";

  src = fetchFromGitHub {
    owner = "jnsgruk";
    repo = "pytouchlinesl";
    tag = version;
    hash = "sha256-o9/K+0ADbU9qTtjLCGM2+aBQsQDP22qdwsgimo9oKns=";
  };

  nativeCheckInputs = [
    pytestCheckHook
    pytest-asyncio
  ];

  build-system = [ setuptools ];

  dependencies = [
    aiohttp
    pydantic
  ];

  pyproject = true;
  pythonImportsCheck = [ "pytouchlinesl" ];

  meta = {
    description = "Python API client for Roth's TouchlineSL API";
    homepage = "https://github.com/jnsgruk/pytouchlinesl";
    changelog = "https://github.com/jnsgruk/pytouchlinesl/releases/tag/${version}";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ jnsgruk ];
  };
}
