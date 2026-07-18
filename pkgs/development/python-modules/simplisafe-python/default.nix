{
  lib,
  fetchFromGitHub,
  aiohttp,
  aresponses,
  backoff,
  beautifulsoup4,
  buildPythonPackage,
  certifi,
  docutils,
  poetry-core,
  pytest-aiohttp,
  pytest-asyncio,
  pytestCheckHook,
  pytz,
  types-pytz,
  voluptuous,
  websockets,
}:

buildPythonPackage (finalAttrs: {
  pname = "simplisafe-python";
  version = "2026.06.0";

  src = fetchFromGitHub {
    owner = "bachya";
    repo = "simplisafe-python";
    tag = finalAttrs.version;
    hash = "sha256-e59h4zX0AuzNlR1sovw4QJ6zXxksElY5emEM9eTfjwI=";
  };

  nativeCheckInputs = [
    aresponses
    pytest-aiohttp
    pytest-asyncio
    pytestCheckHook
    types-pytz
  ];

  __darwinAllowLocalNetworking = true;
  build-system = [ poetry-core ];

  dependencies = [
    aiohttp
    backoff
    beautifulsoup4
    certifi
    docutils
    pytz
    voluptuous
    websockets
  ];

  disabledTestPaths = [
    # Ignore the examples as they are prefixed with test_
    "examples/"
  ];

  disabledTests = [
    # simplipy/api.py:253: InvalidCredentialsError
    "test_request_error_failed_retry"
    "test_update_error"
    # ClientConnectorError: Cannot connect to host auth.simplisafe.com:443 ssl:default [Temporary failure in name resolution]
    "test_client_async_from_refresh_token_unknown_error"
  ];

  pyproject = true;
  pythonImportsCheck = [ "simplipy" ];

  meta = {
    description = "Python library the SimpliSafe API";
    homepage = "https://simplisafe-python.readthedocs.io/";
    changelog = "https://github.com/bachya/simplisafe-python/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ fab ];
  };
})
