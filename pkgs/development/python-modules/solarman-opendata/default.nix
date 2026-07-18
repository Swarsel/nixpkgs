{
  lib,
  fetchFromGitHub,
  aiohttp,
  buildPythonPackage,
  pytest-asyncio,
  pytest-cov-stub,
  pytest-mock,
  pytestCheckHook,
  setuptools,
  wheel,
}:

buildPythonPackage (finalAttrs: {
  pname = "solarman-opendata";
  version = "0.0.3";

  src = fetchFromGitHub {
    owner = "solarmanpv";
    repo = "solarman-opendata";
    tag = "v${finalAttrs.version}";
    hash = "sha256-mLwvAs+RFaHXjOgMaIhKKTU4Dqzdu/pLtAwYc/B6oj4=";
  };

  nativeCheckInputs = [
    pytest-asyncio
    pytest-cov-stub
    pytest-mock
    pytestCheckHook
  ];

  build-system = [
    setuptools
  ];

  dependencies = [
    aiohttp
  ];

  pyproject = true;
  pythonImportsCheck = [ "solarman_opendata" ];

  meta = {
    description = "Asynchronous Python API for Solarman devices";
    homepage = "https://github.com/solarmanpv/solarman-opendata";
    changelog = "https://github.com/solarmanpv/solarman-opendata/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.asl20;
    maintainers = [ lib.maintainers.jamiemagee ];
  };
})
