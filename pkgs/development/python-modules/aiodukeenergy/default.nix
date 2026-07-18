{
  lib,
  fetchFromGitHub,
  aiohttp,
  aioresponses,
  buildPythonPackage,
  poetry-core,
  pyjwt,
  pytest-asyncio,
  pytest-cov-stub,
  pytestCheckHook,
  yarl,
}:

buildPythonPackage rec {
  pname = "aiodukeenergy";
  version = "1.1.0";

  src = fetchFromGitHub {
    owner = "hunterjm";
    repo = "aiodukeenergy";
    tag = "v${version}";
    hash = "sha256-v8rWRjAlTGu7d0bQaAQ1A7Qm4oP3STkIzHcKLa8+/OY=";
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
    pyjwt
    yarl
  ];

  pyproject = true;
  pythonImportsCheck = [ "aiodukeenergy" ];

  meta = {
    description = "Asyncio Duke Energy";
    homepage = "https://github.com/hunterjm/aiodukeenergy";
    changelog = "https://github.com/hunterjm/aiodukeenergy/blob/${src.tag}/CHANGELOG.md";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ dotlambda ];
  };
}
