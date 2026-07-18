{
  lib,
  fetchFromGitHub,
  aiohttp,
  aioresponses,
  buildPythonPackage,
  pytest-asyncio,
  pytestCheckHook,
  setuptools,
}:

buildPythonPackage rec {
  pname = "ekey-bionyxpy";
  version = "1.0.1";

  src = fetchFromGitHub {
    owner = "richardpolzer";
    repo = "ekey-bionyx-api";
    tag = version;
    hash = "sha256-V4xYv+mjU4QO/+hOq3TH8b/X9PVP95i6apYkcqVDIWY=";
  };

  nativeCheckInputs = [
    aioresponses
    pytest-asyncio
    pytestCheckHook
  ];

  build-system = [ setuptools ];
  dependencies = [ aiohttp ];
  pyproject = true;
  pythonImportsCheck = [ "ekey_bionyxpy" ];

  meta = {
    description = "Interact with the bionyx third party API of the ekey biometric systems";
    homepage = "https://github.com/richardpolzer/ekey-bionyx-api";
    changelog = "https://github.com/richardpolzer/ekey-bionyx-api/releases/tag/${version}";
    license = lib.licenses.mit;
    maintainers = [ lib.maintainers.jamiemagee ];
  };
}
