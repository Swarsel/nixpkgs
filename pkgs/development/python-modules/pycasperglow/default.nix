{
  lib,
  fetchFromGitHub,
  bleak,
  bleak-retry-connector,
  buildPythonPackage,
  pytest-asyncio,
  pytestCheckHook,
  setuptools,
}:

buildPythonPackage (finalAttrs: {
  pname = "pycasperglow";
  version = "1.2.0";

  src = fetchFromGitHub {
    owner = "mikeodr";
    repo = "pycasperglow";
    tag = "v${finalAttrs.version}";
    hash = "sha256-sLjEo8GSGBtx0GDAHQZad5ePQAwzChdmBE5TU+ebuFI=";
  };

  nativeCheckInputs = [
    pytest-asyncio
    pytestCheckHook
  ];

  build-system = [ setuptools ];

  dependencies = [
    bleak
    bleak-retry-connector
  ];

  pyproject = true;
  pythonImportsCheck = [ "pycasperglow" ];

  meta = {
    description = "Async Python library for controlling Casper Glow lights via BLE";
    homepage = "https://github.com/mikeodr/pycasperglow";
    changelog = "https://github.com/mikeodr/pycasperglow/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.mit;
    maintainers = [ lib.maintainers.jamiemagee ];
  };
})
