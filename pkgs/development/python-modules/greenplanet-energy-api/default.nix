{
  lib,
  fetchFromGitHub,
  aiohttp,
  aioresponses,
  buildPythonPackage,
  pytest-asyncio,
  pytest-cov-stub,
  pytestCheckHook,
  setuptools,
}:

buildPythonPackage (finalAttrs: {
  pname = "greenplanet-energy-api";
  version = "0.1.10";

  src = fetchFromGitHub {
    owner = "petschni";
    repo = "greenplanet-energy-api";
    tag = "v${finalAttrs.version}";
    hash = "sha256-2Maz/deWoHO92ed+k7EqJg6KhdARHl46IN/d/6E3W8E=";
  };

  nativeCheckInputs = [
    pytest-asyncio
    pytest-cov-stub
    aioresponses
    pytestCheckHook
  ];

  build-system = [ setuptools ];

  dependencies = [
    aiohttp
  ];

  disabledTests = [
    # connects to mein.green-planet-energy.de
    "test_get_electricity_prices_timeout"
  ];

  pyproject = true;
  pythonImportsCheck = [ "greenplanet_energy_api" ];

  meta = {
    description = "Async Python library for querying the Green Planet Energy API";
    homepage = "https://github.com/petschni/greenplanet-energy-api";
    changelog = "https://github.com/petschni/greenplanet-energy-api/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.mit;
    maintainers = [ lib.maintainers.jamiemagee ];
  };
})
