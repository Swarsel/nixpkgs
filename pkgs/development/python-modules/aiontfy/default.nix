{
  lib,
  fetchFromGitHub,
  aiohttp,
  buildPythonPackage,
  hatch-regex-commit,
  hatchling,
  mashumaro,
  orjson,
  pytest-asyncio,
  pytest-cov-stub,
  pytestCheckHook,
}:

buildPythonPackage rec {
  pname = "aiontfy";
  version = "0.8.5";

  src = fetchFromGitHub {
    owner = "tr4nt0r";
    repo = "aiontfy";
    tag = "v${version}";
    hash = "sha256-LDt8JapUQcojMWyW931zt3U4QMwQew4wOly2AyYvbkI=";
  };

  nativeCheckInputs = [
    pytest-asyncio
    pytest-cov-stub
    pytestCheckHook
  ];

  build-system = [
    hatch-regex-commit
    hatchling
  ];

  dependencies = [
    aiohttp
    mashumaro
    orjson
  ];

  pyproject = true;
  pythonImportsCheck = [ "aiontfy" ];

  meta = {
    description = "Async ntfy client library";
    homepage = "https://github.com/tr4nt0r/aiontfy";
    changelog = "https://github.com/tr4nt0r/aiontfy/releases/tag/${src.tag}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ dotlambda ];
  };
}
