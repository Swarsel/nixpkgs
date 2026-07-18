{
  lib,
  fetchFromGitHub,
  # dependencies
  aiohttp,
  # tests
  aioresponses,
  buildPythonPackage,
  incremental,
  pytest-aiohttp,
  pytest-asyncio,
  pytest-socket,
  pytestCheckHook,
  pythonOlder,
  # build-system
  setuptools,
  syrupy,
}:

buildPythonPackage rec {
  pname = "aioazuredevops";
  version = "2.2.2";

  src = fetchFromGitHub {
    owner = "timmo001";
    repo = "aioazuredevops";
    tag = version;
    hash = "sha256-0KQHL9DmNeRvEs51XPcncxNzXb+SqYM5xPDvOdKSQMI=";
  };

  nativeCheckInputs = [
    aioresponses
    pytest-aiohttp
    pytest-asyncio
    pytest-socket
    pytestCheckHook
    syrupy
  ];

  build-system = [
    incremental
    setuptools
  ];

  dependencies = [
    aiohttp
    incremental
  ];

  disabled = pythonOlder "3.12";

  disabledTestPaths = [
    # https://github.com/timmo001/aioazuredevops/commit/d6278d92937dd47de272ac6371b2d007067763c3
    "tests/test__version.py"
  ];

  disabledTests = [
    # https://github.com/timmo001/aioazuredevops/issues/44
    "test_get_project"
    "test_get_builds"
    "test_get_build"
  ];

  pyproject = true;
  pytestFlags = [ "--snapshot-update" ];
  pythonImportsCheck = [ "aioazuredevops" ];

  meta = {
    description = "Get data from the Azure DevOps API";
    homepage = "https://github.com/timmo001/aioazuredevops";
    changelog = "https://github.com/timmo001/aioazuredevops/releases/tag/${version}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ dotlambda ];
  };
}
