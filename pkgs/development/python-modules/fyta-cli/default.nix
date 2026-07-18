{
  lib,
  fetchFromGitHub,
  aiohttp,
  aioresponses,
  buildPythonPackage,
  hatchling,
  mashumaro,
  pytest-asyncio,
  pytestCheckHook,
  syrupy,
}:

buildPythonPackage (finalAttrs: {
  pname = "fyta-cli";
  version = "0.7.3";

  src = fetchFromGitHub {
    owner = "dontinelli";
    repo = "fyta_cli";
    tag = "v${finalAttrs.version}";
    hash = "sha256-+gPPECRMhhx7H+K3//PRH3ALyY2k6eQ/o9qAVHyyoes=";
  };

  doCheck = false; # Failed: async def functions are not natively supported.

  nativeCheckInputs = [
    aioresponses
    pytest-asyncio
    pytestCheckHook
    syrupy
  ];

  build-system = [ hatchling ];

  dependencies = [
    aiohttp
    mashumaro
  ];

  pyproject = true;
  pytestFlags = [ "--snapshot-update" ];
  pythonImportsCheck = [ "fyta_cli" ];

  meta = {
    description = "Module to access the FYTA API";
    homepage = "https://github.com/dontinelli/fyta_cli";
    changelog = "https://github.com/dontinelli/fyta_cli/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.gpl3Only;
    maintainers = with lib.maintainers; [ fab ];
  };
})
