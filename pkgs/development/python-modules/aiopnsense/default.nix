{
  lib,
  fetchFromGitHub,
  aiohttp,
  awesomeversion,
  buildPythonPackage,
  pytest-asyncio,
  pytest-cov-stub,
  pytest-timeout,
  pytestCheckHook,
  python-dateutil,
  pythonOlder,
  setuptools,
}:

buildPythonPackage (finalAttrs: {
  pname = "aiopnsense";
  version = "1.1.0";

  src = fetchFromGitHub {
    owner = "Snuffy2";
    repo = "aiopnsense";
    tag = "v${finalAttrs.version}";
    hash = "sha256-Ffp0CTYqqeeB8462luTvpa2dp2QOxztkipretBqaKig=";
  };

  nativeCheckInputs = [
    aiohttp
    pytest-asyncio
    pytest-cov-stub
    pytest-timeout
    pytestCheckHook
  ];

  build-system = [ setuptools ];

  dependencies = [
    aiohttp
    awesomeversion
    python-dateutil
  ];

  disabled = pythonOlder "3.14";
  pyproject = true;
  pythonImportsCheck = [ "aiopnsense" ];

  meta = {
    description = "Async Python client library for OPNsense";
    homepage = "https://github.com/Snuffy2/aiopnsense";
    changelog = "https://github.com/Snuffy2/aiopnsense/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.asl20;
    maintainers = [ lib.maintainers.jamiemagee ];
  };
})
