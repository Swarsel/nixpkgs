{
  lib,
  fetchFromGitHub,
  aiohttp,
  aresponses,
  async-timeout,
  backoff,
  buildPythonPackage,
  pytest-asyncio,
  pytestCheckHook,
  setuptools,
}:

buildPythonPackage (finalAttrs: {
  pname = "aiocentriconnect";
  version = "0.2.3";

  src = fetchFromGitHub {
    owner = "gresrun";
    repo = "aiocentriconnect";
    tag = "v${finalAttrs.version}";
    hash = "sha256-CBCD5JMUBD0NpkUVIaCXdsbKYgucELs11Pk9z0YufQw=";
  };

  nativeCheckInputs = [
    aresponses
    pytest-asyncio
    pytestCheckHook
  ];

  build-system = [ setuptools ];

  dependencies = [
    aiohttp
    async-timeout
    backoff
  ];

  pyproject = true;
  pythonImportsCheck = [ "aiocentriconnect" ];

  meta = {
    description = "Asynchronous Python client for CentriConnect/MyPropane API";
    homepage = "https://github.com/gresrun/aiocentriconnect";
    changelog = "https://github.com/gresrun/aiocentriconnect/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.mit;
    maintainers = [ lib.maintainers.jamiemagee ];
  };
})
