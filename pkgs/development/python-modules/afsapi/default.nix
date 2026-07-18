{
  lib,
  fetchFromGitHub,
  aiohttp,
  buildPythonPackage,
  defusedxml,
  hatch-vcs,
  hatchling,
  pytest-aiohttp,
  pytestCheckHook,
}:

buildPythonPackage (finalAttrs: {
  pname = "afsapi";
  version = "1.0.1";

  src = fetchFromGitHub {
    owner = "wlcrs";
    repo = "python-afsapi";
    tag = finalAttrs.version;
    hash = "sha256-OMz8zJrU1qymvhD9mnf248687wpqfgUnXna7Cbr83No=";
  };

  doCheck = false; # Failed: async def functions are not natively supported.

  nativeCheckInputs = [
    pytest-aiohttp
    pytestCheckHook
  ];

  build-system = [
    hatchling
    hatch-vcs
  ];

  dependencies = [
    aiohttp
    defusedxml
  ];

  enabledTestPaths = [ "async_tests.py" ];
  pyproject = true;
  pythonImportsCheck = [ "afsapi" ];

  meta = {
    description = "Python implementation of the Frontier Silicon API";
    homepage = "https://github.com/wlcrs/python-afsapi";
    changelog = "https://github.com/wlcrs/python-afsapi/releases/tag/${finalAttrs.version}";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ fab ];
  };
})
