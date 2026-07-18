{
  lib,
  fetchFromGitHub,
  aiohttp,
  aioresponses,
  buildPythonPackage,
  mashumaro,
  orjson,
  poetry-core,
  pytest-asyncio,
  pytest-cov-stub,
  pytestCheckHook,
  syrupy,
  yarl,
}:

buildPythonPackage rec {
  pname = "nyt-games";
  version = "0.5.0";

  src = fetchFromGitHub {
    owner = "joostlek";
    repo = "python-nyt-games";
    tag = "v${version}";
    hash = "sha256-bpamhrTBDFp1c/RvvbVjRFXEn5HoxY+3jGH7NkfsFxo=";
  };

  nativeCheckInputs = [
    aioresponses
    pytest-asyncio
    pytest-cov-stub
    pytestCheckHook
    syrupy
  ];

  build-system = [ poetry-core ];

  dependencies = [
    aiohttp
    mashumaro
    orjson
    yarl
  ];

  pyproject = true;
  pythonImportsCheck = [ "nyt_games" ];

  meta = {
    description = "Asynchronous Python client for NYT games";
    homepage = "https://github.com/joostlek/python-nyt-games";
    changelog = "https://github.com/joostlek/python-nyt-games/releases/tag/${src.tag}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ dotlambda ];
  };
}
