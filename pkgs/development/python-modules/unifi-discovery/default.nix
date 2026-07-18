{
  lib,
  fetchFromGitHub,
  aiohttp,
  aioresponses,
  buildPythonPackage,
  poetry-core,
  pyroute2,
  pytest-asyncio,
  pytest-cov-stub,
  pytestCheckHook,
}:

buildPythonPackage (finalAttrs: {
  pname = "unifi-discovery";
  version = "1.5.0";

  src = fetchFromGitHub {
    owner = "bdraco";
    repo = "unifi-discovery";
    tag = "v${finalAttrs.version}";
    hash = "sha256-nL1liMg7qImY4AXdhvLbLXgZs/S3eypQCSJF5yZldmU=";
  };

  nativeCheckInputs = [
    aioresponses
    pytest-asyncio
    pytest-cov-stub
    pytestCheckHook
  ];

  build-system = [ poetry-core ];

  dependencies = [
    aiohttp
    pyroute2
  ];

  pyproject = true;
  pytestFlags = [ "--asyncio-mode=auto" ];
  pythonImportsCheck = [ "unifi_discovery" ];

  meta = {
    description = "Module to discover Unifi devices";
    homepage = "https://github.com/bdraco/unifi-discovery";
    changelog = "https://github.com/bdraco/unifi-discovery/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ fab ];
    platforms = lib.platforms.linux;
  };
})
