{
  lib,
  fetchFromGitHub,
  aiohttp,
  aiohttp-retry,
  buildPythonPackage,
  freezegun,
  ical,
  mashumaro,
  parameterized,
  pycryptodome,
  pytest-aiohttp,
  pytest-asyncio,
  pytest-cov-stub,
  pytest-golden,
  pytest-mock,
  pytestCheckHook,
  python-dateutil,
  pyyaml,
  setuptools,
  syrupy,
}:

buildPythonPackage (finalAttrs: {
  pname = "pyrainbird";
  version = "6.5.0";

  src = fetchFromGitHub {
    owner = "allenporter";
    repo = "pyrainbird";
    tag = finalAttrs.version;
    hash = "sha256-JPnp77NhgT878sQJ7Az58R6JnMuprr69rPiZjkh+E1I=";
  };

  nativeCheckInputs = [
    freezegun
    parameterized
    pytest-aiohttp
    pytest-asyncio
    pytest-cov-stub
    pytest-golden
    pytest-mock
    pytestCheckHook
    syrupy
  ];

  __darwinAllowLocalNetworking = true;
  build-system = [ setuptools ];

  dependencies = [
    aiohttp
    aiohttp-retry
    ical
    mashumaro
    pycryptodome
    python-dateutil
    pyyaml
  ];

  pyproject = true;
  pythonImportsCheck = [ "pyrainbird" ];

  pythonRelaxDeps = [
    "aiohttp"
  ];

  meta = {
    description = "Module to interact with Rainbird controllers";
    homepage = "https://github.com/allenporter/pyrainbird";
    changelog = "https://github.com/allenporter/pyrainbird/releases/tag/${finalAttrs.version}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ fab ];
  };
})
