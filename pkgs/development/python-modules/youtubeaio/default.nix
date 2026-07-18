{
  lib,
  fetchFromGitHub,
  aiohttp,
  aresponses,
  buildPythonPackage,
  poetry-core,
  pydantic,
  pytest-asyncio,
  pytest-cov-stub,
  pytestCheckHook,
  syrupy,
  yarl,
}:

buildPythonPackage rec {
  pname = "youtubeaio";
  version = "2.1.2";

  src = fetchFromGitHub {
    owner = "joostlek";
    repo = "python-youtube";
    tag = "v${version}";
    hash = "sha256-GE06T3NSA2JdPSd2kS7rf3abI+b/zegS34n3Oxj2tnE=";
  };

  nativeCheckInputs = [
    aresponses
    pytest-asyncio
    pytest-cov-stub
    pytestCheckHook
    syrupy
  ];

  build-system = [ poetry-core ];

  dependencies = [
    aiohttp
    pydantic
    yarl
  ];

  pyproject = true;
  pythonImportsCheck = [ "youtubeaio" ];

  meta = {
    description = "Asynchronous Python client for the YouTube V3 API";
    homepage = "https://github.com/joostlek/python-youtube";
    changelog = "https://github.com/joostlek/python-youtube/releases/tag/${src.tag}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ dotlambda ];
  };
}
