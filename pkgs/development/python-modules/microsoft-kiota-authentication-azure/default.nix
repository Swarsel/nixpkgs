{
  lib,
  fetchFromGitHub,
  aiohttp,
  azure-core,
  buildPythonPackage,
  flit-core,
  gitUpdater,
  microsoft-kiota-abstractions,
  opentelemetry-api,
  opentelemetry-sdk,
  pytest-asyncio,
  pytest-mock,
  pytestCheckHook,
}:

buildPythonPackage (finalAttrs: {
  pname = "microsoft-kiota-authentication-azure";
  version = "1.11.7";

  src = fetchFromGitHub {
    owner = "microsoft";
    repo = "kiota-python";
    tag = "microsoft-kiota-authentication-azure-v${finalAttrs.version}";
    hash = "sha256-Fd9XSO3H1Au8y+Acft5to7hi7QNwWcmP0/NeWZlufjg=";
  };

  nativeCheckInputs = [
    pytest-asyncio
    pytest-mock
    pytestCheckHook
  ];

  build-system = [ flit-core ];

  dependencies = [
    aiohttp
    azure-core
    microsoft-kiota-abstractions
    opentelemetry-api
    opentelemetry-sdk
  ];

  pyproject = true;
  pythonImportsCheck = [ "kiota_authentication_azure" ];
  sourceRoot = "${finalAttrs.src.name}/packages/authentication/azure/";

  passthru.updateScript = gitUpdater {
    rev-prefix = "microsoft-kiota-authentication-azure-v";
  };

  meta = {
    description = "Kiota Azure authentication provider";
    homepage = "https://github.com/microsoft/kiota-python/tree/main/packages/authentication/azure";
    changelog = "https://github.com/microsoft/kiota-python/releases/tag/microsoft-kiota-authentication-azure-${finalAttrs.src.tag}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ fab ];
  };
})
