{
  lib,
  fetchFromGitHub,
  aiohttp,
  buildPythonPackage,
  dacite,
  hatchling,
  pytest-asyncio,
  pytestCheckHook,
  uv-dynamic-versioning,
}:

buildPythonPackage (finalAttrs: {
  pname = "pyintelliclima";
  version = "0.3.1";

  src = fetchFromGitHub {
    owner = "dvdinth";
    repo = "pyintelliclima";
    tag = "v${finalAttrs.version}";
    hash = "sha256-EHcnrynvNIfo31vZyh8tS/5JfFuEQGVlYzu4XyD3XCI=";
  };

  nativeCheckInputs = [
    pytest-asyncio
    pytestCheckHook
  ];

  build-system = [
    hatchling
    uv-dynamic-versioning
  ];

  dependencies = [
    aiohttp
    dacite
  ];

  pyproject = true;
  pythonImportsCheck = [ "pyintelliclima" ];
  pythonRelaxDeps = [ "dacite" ];

  meta = {
    description = "Python module for a HTTP API to communicate with the IntelliClima device server";
    homepage = "https://github.com/dvdinth/pyintelliclima";
    changelog = "https://github.com/dvdinth/pyintelliclima/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.mit;
    maintainers = [ lib.maintainers.jamiemagee ];
  };
})
