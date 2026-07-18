{
  lib,
  fetchFromGitHub,
  aiohttp,
  aresponses,
  buildPythonPackage,
  freezegun,
  hatchling,
  mashumaro,
  orjson,
  pytest-cov-stub,
  pytestCheckHook,
  syrupy,
  tenacity,
  yarl,
}:

buildPythonPackage (finalAttrs: {
  pname = "pyportainer";
  version = "1.0.41";

  src = fetchFromGitHub {
    owner = "erwindouna";
    repo = "pyportainer";
    tag = "v${finalAttrs.version}";
    hash = "sha256-pQGObEYmj5Off573wwxLdU6p+kJsGqDyPVPzmD6vCc8=";
  };

  nativeCheckInputs = [
    aresponses
    freezegun
    pytest-cov-stub
    pytestCheckHook
    syrupy
  ];

  build-system = [ hatchling ];

  dependencies = [
    aiohttp
    mashumaro
    orjson
    tenacity
    yarl
  ];

  pyproject = true;
  pythonImportsCheck = [ "pyportainer" ];

  meta = {
    description = "Asynchronous Python client for the Portainer API";
    homepage = "https://github.com/erwindouna/pyportainer";
    changelog = "https://github.com/erwindouna/pyportainer/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.mit;
    maintainers = [ lib.maintainers.dotlambda ];
  };
})
