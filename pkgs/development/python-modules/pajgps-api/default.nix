{
  lib,
  fetchFromGitHub,
  aiohttp,
  buildPythonPackage,
  hatchling,
  pytestCheckHook,
  python-dotenv,
}:

buildPythonPackage (finalAttrs: {
  pname = "pajgps-api";
  version = "0.4.0";

  src = fetchFromGitHub {
    owner = "skipperro";
    repo = "pajgps-api";
    tag = finalAttrs.version;
    hash = "sha256-7NVr75ss9vUjyn0Yz+bpZVdN4gDx4gvpdDV1bWLKOIQ=";
  };

  nativeCheckInputs = [
    pytestCheckHook
    python-dotenv
  ];

  build-system = [ hatchling ];
  dependencies = [ aiohttp ];
  pyproject = true;
  pythonImportsCheck = [ "pajgps_api" ];

  meta = {
    description = "Python library to interact with the PAJ GPS API";
    homepage = "https://github.com/skipperro/pajgps-api";
    changelog = "https://github.com/skipperro/pajgps-api/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.mit;
    maintainers = [ lib.maintainers.jamiemagee ];
  };
})
