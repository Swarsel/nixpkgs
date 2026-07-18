{
  lib,
  fetchFromGitHub,
  aiohttp,
  aioresponses,
  awesomeversion,
  buildPythonPackage,
  freezegun,
  pytest-asyncio,
  pytestCheckHook,
  setuptools,
  setuptools-scm,
}:

buildPythonPackage (finalAttrs: {
  pname = "python-openevse-http";
  version = "1.0.1";

  src = fetchFromGitHub {
    owner = "firstof9";
    repo = "python-openevse-http";
    tag = finalAttrs.version;
    hash = "sha256-X87nS/h+Lh//rf8pNrlX22HOpT3Bz/6QgWBfQEaDQP8=";
  };

  nativeCheckInputs = [
    aioresponses
    freezegun
    pytestCheckHook
    pytest-asyncio
  ];

  build-system = [
    setuptools
    setuptools-scm
  ];

  dependencies = [
    aiohttp
    awesomeversion
  ];

  pyproject = true;
  pythonImportsCheck = [ "openevsehttp" ];

  meta = {
    description = "Python wrapper for OpenEVSE HTTP API";
    homepage = "https://github.com/firstof9/python-openevse-http";
    changelog = "https://github.com/firstof9/python-openevse-http/releases/tag/${finalAttrs.version}";
    license = lib.licenses.asl20;
    maintainers = [ lib.maintainers.jamiemagee ];
  };
})
