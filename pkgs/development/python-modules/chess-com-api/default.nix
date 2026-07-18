{
  lib,
  fetchFromGitHub,
  aiohttp,
  buildPythonPackage,
  hatchling,
  pytest-asyncio,
  pytest-cov-stub,
  pytest-mock,
  pytestCheckHook,
}:

buildPythonPackage (finalAttrs: {
  pname = "chess-com-api";
  version = "1.1.0";

  src = fetchFromGitHub {
    owner = "Stupidoodle";
    repo = "chess-com-api";
    tag = "v${finalAttrs.version}";
    hash = "sha256-/84rDQwD1Qxl1x7AOF6KFTYqYOdqQyzuhgiz5gArMmo=";
  };

  nativeCheckInputs = [
    pytestCheckHook
    pytest-asyncio
    pytest-cov-stub
    pytest-mock
  ];

  build-system = [ hatchling ];
  dependencies = [ aiohttp ];

  disabledTestPaths = [
    # require network access
    "tests/test_client.py"
    "tests/test_integration.py"
  ];

  pyproject = true;
  pythonImportsCheck = [ "chess_com_api" ];

  meta = {
    description = "An async Python wrapper for the Chess.com API";
    homepage = "https://github.com/Stupidoodle/chess-com-api";
    changelog = "https://github.com/Stupidoodle/chess-com-api/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.mit;
    maintainers = [ lib.maintainers.jamiemagee ];
  };
})
