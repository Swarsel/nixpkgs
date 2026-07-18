{
  lib,
  fetchFromGitHub,
  aiohttp,
  buildPythonPackage,
  pytest-asyncio,
  pytest-timeout,
  pytestCheckHook,
  setuptools,
}:

buildPythonPackage (finalAttrs: {
  pname = "pyliebherrhomeapi";
  version = "0.4.1";

  src = fetchFromGitHub {
    owner = "mettolen";
    repo = "pyliebherrhomeapi";
    tag = finalAttrs.version;
    hash = "sha256-f0+2gqNLeyLP6rOAWay+T04ry21SPA79pm+prG7kJtc=";
  };

  nativeCheckInputs = [
    pytestCheckHook
    pytest-asyncio
    pytest-timeout
  ];

  build-system = [ setuptools ];
  dependencies = [ aiohttp ];
  pyproject = true;
  pythonImportsCheck = [ "pyliebherrhomeapi" ];

  meta = {
    description = "Python library for Liebherr Home API";
    homepage = "https://github.com/mettolen/pyliebherrhomeapi";
    changelog = "https://github.com/mettolen/pyliebherrhomeapi/releases/tag/${finalAttrs.version}";
    license = lib.licenses.mit;
    maintainers = [ lib.maintainers.jamiemagee ];
  };
})
