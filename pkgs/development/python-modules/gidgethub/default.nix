{
  lib,
  aiohttp,
  buildPythonPackage,
  fetchPypi,
  flit-core,
  httpx,
  importlib-resources,
  pyjwt,
  pytest-asyncio,
  pytest-tornasync,
  pytestCheckHook,
  uritemplate,
}:

buildPythonPackage rec {
  pname = "gidgethub";
  version = "5.4.0";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-dHDXcj18F0NHGi1i55yHUvuhKxwJcuS61XJSM4pQHb0=";
  };

  nativeCheckInputs = [
    pytestCheckHook
    aiohttp
    httpx
    importlib-resources
    pytest-asyncio
    pytest-tornasync
  ];

  build-system = [ flit-core ];

  dependencies = [
    uritemplate
    pyjwt
  ]
  ++ pyjwt.optional-dependencies.crypto;

  disabledTests = [
    # Require internet connection
    "test__request"
    "test_get"
  ];

  pyproject = true;

  meta = {
    description = "Async GitHub API library";
    homepage = "https://github.com/brettcannon/gidgethub";
    license = lib.licenses.asl20;
    maintainers = [ ];
  };
}
