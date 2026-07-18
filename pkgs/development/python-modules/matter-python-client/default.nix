{
  lib,
  fetchFromGitHub,
  # dependencies
  aiohttp,
  buildPythonPackage,
  home-assistant-chip-clusters,
  orjson,
  pytest-aiohttp,
  # tests
  pytest-asyncio,
  pytestCheckHook,
  # build-system
  setuptools,
}:

buildPythonPackage (finalAttrs: {
  pname = "matter-python-client";
  version = "0.8.0";

  src = fetchFromGitHub {
    owner = "matter-js";
    repo = "matterjs-server";
    tag = "v${finalAttrs.version}";
    hash = "sha256-AjCfPovhYKUeU4Xrsh6uL0pPG+ja0n+efFTbwre83m4=";
  };

  postPatch = ''
    substituteInPlace pyproject.toml \
      --replace 'version = "0.0.0"' 'version = "${finalAttrs.version}"'
  '';

  nativeCheckInputs = [
    pytest-asyncio
    pytest-aiohttp
    pytestCheckHook
  ];

  build-system = [ setuptools ];

  dependencies = [
    aiohttp
    orjson
    home-assistant-chip-clusters
  ];

  disabledTestPaths = [
    # requires npx and network access to start matterjs
    "tests/test_client_integration.py"
    "tests/test_integration.py"
  ];

  pyproject = true;

  pythonImportsCheck = [
    "matter_server.client"
  ];

  sourceRoot = "${finalAttrs.src.name}/python_client";

  meta = {
    description = "Python Client for the OHF Matter Server";
    homepage = "https://github.com/matter-js/matterjs-server/tree/main/python_client";
    changelog = "https://github.com/matter-js/matterjs-server/blob/${finalAttrs.src.tag}/CHANGELOG.md";
    license = lib.licenses.asl20;
    teams = [ lib.teams.home-assistant ];
  };
})
