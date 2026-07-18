{
  lib,
  fetchFromGitHub,
  aiohttp,
  aioresponses,
  buildPythonPackage,
  mashumaro,
  pytest-aiohttp,
  pytest-cov-stub,
  pytestCheckHook,
  setuptools,
}:

buildPythonPackage (finalAttrs: {
  pname = "aioopenexchangerates";
  version = "0.7.0";

  src = fetchFromGitHub {
    owner = "MartinHjelmare";
    repo = "aioopenexchangerates";
    tag = "v${finalAttrs.version}";
    hash = "sha256-pNjpeoXBlz2bdUeEsOlW7RJmbKTZGuBVTLHymGHwAiY=";
  };

  nativeCheckInputs = [
    aioresponses
    pytest-aiohttp
    pytest-cov-stub
    pytestCheckHook
  ];

  build-system = [ setuptools ];

  dependencies = [
    aiohttp
    mashumaro
  ];

  pyproject = true;
  pythonImportsCheck = [ "aioopenexchangerates" ];
  pythonRelaxDeps = [ "pydantic" ];

  meta = {
    description = "Library for the Openexchangerates API";
    homepage = "https://github.com/MartinHjelmare/aioopenexchangerates";
    changelog = "https://github.com/MartinHjelmare/aioopenexchangerates/blob/v${finalAttrs.version}/CHANGELOG.md";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ fab ];
  };
})
