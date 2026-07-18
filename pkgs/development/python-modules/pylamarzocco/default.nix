{
  lib,
  fetchFromGitHub,
  aiohttp,
  aioresponses,
  bleak,
  bleak-retry-connector,
  buildPythonPackage,
  cryptography,
  mashumaro,
  pytest-asyncio,
  pytestCheckHook,
  setuptools,
  syrupy,
}:

buildPythonPackage (finalAttrs: {
  pname = "pylamarzocco";
  version = "2.4.2";

  src = fetchFromGitHub {
    owner = "zweckj";
    repo = "pylamarzocco";
    tag = "v${finalAttrs.version}";
    hash = "sha256-9wqSF67MNxnGvDDDVY9epI3hoV8M20L3Fyz80/x8G74=";
  };

  nativeCheckInputs = [
    aioresponses
    pytest-asyncio
    pytestCheckHook
    syrupy
  ];

  build-system = [ setuptools ];

  dependencies = [
    aiohttp
    bleak
    bleak-retry-connector
    cryptography
    mashumaro
  ];

  pyproject = true;
  pythonImportsCheck = [ "pylamarzocco" ];

  meta = {
    description = "Library to interface with La Marzocco's cloud";
    homepage = "https://github.com/zweckj/pylamarzocco";
    changelog = "https://github.com/zweckj/pylamarzocco/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ fab ];
  };
})
