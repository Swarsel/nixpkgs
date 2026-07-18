{
  lib,
  fetchFromGitHub,
  aiohttp,
  aioresponses,
  buildPythonPackage,
  hatch-regex-commit,
  hatchling,
  mashumaro,
  orjson,
  pillow,
  pytest-asyncio,
  pytest-cov-stub,
  pytestCheckHook,
  pythonOlder,
  syrupy,
}:

buildPythonPackage rec {
  pname = "habiticalib";
  version = "0.4.7";

  src = fetchFromGitHub {
    owner = "tr4nt0r";
    repo = "habiticalib";
    tag = "v${version}";
    hash = "sha256-ZZY7UnA4d4JNHGLMtaEGobAgzAwYDgL2SUGfxGABxTs=";
  };

  nativeCheckInputs = [
    aioresponses
    pytest-asyncio
    pytest-cov-stub
    pytestCheckHook
    syrupy
  ];

  build-system = [
    hatch-regex-commit
    hatchling
  ];

  dependencies = [
    aiohttp
    mashumaro
    orjson
    pillow
  ];

  disabled = pythonOlder "3.12";

  disabledTests = [
    # AssertionError
    "test_generate_avatar"
  ];

  pyproject = true;
  pythonImportsCheck = [ "habiticalib" ];

  pythonRelaxDeps = [
    "orjson"
  ];

  meta = {
    description = "Library for the Habitica API";
    homepage = "https://github.com/tr4nt0r/habiticalib";
    changelog = "https://github.com/tr4nt0r/habiticalib/releases/tag/${src.tag}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ fab ];
  };
}
