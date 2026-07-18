{
  lib,
  fetchFromGitHub,
  aiohttp,
  aresponses,
  backoff,
  buildPythonPackage,
  fetchpatch,
  pytest-asyncio,
  pytestCheckHook,
  setuptools,
  yarl,
}:

buildPythonPackage rec {
  pname = "aiomodernforms";
  version = "0.1.8";

  src = fetchFromGitHub {
    owner = "wonderslug";
    repo = "aiomodernforms";
    rev = "v${version}";
    hash = "sha256-Vx51WBjjNPIfLlwMnAuwHnGNljhnjKkU0tWB9M9rjsw=";
  };

  patches = [
    # https://github.com/wonderslug/aiomodernforms/pull/274
    (fetchpatch {
      hash = "sha256-7sy5/HgPYgVpULgeEu3tFBa2iXIskAqcarf0RndxTpE=";
      name = "replace-async-timeout-with-asyncio.timeout.patch";
      url = "https://github.com/wonderslug/aiomodernforms/commit/61f1330b2fc244565fd97ae392b9778faa1bab09.patch";
    })
  ];

  nativeCheckInputs = [
    aresponses
    pytest-asyncio
    pytestCheckHook
  ];

  __darwinAllowLocalNetworking = true;
  build-system = [ setuptools ];

  dependencies = [
    aiohttp
    backoff
    yarl
  ];

  disabledTests = [
    # https://github.com/wonderslug/aiomodernforms/issues/273
    "test_connection_error"
    "test_empty_response"
  ];

  pyproject = true;
  pythonImportsCheck = [ "aiomodernforms" ];

  meta = {
    description = "Asynchronous Python client for Modern Forms fans";
    homepage = "https://github.com/wonderslug/aiomodernforms";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ dotlambda ];
  };
}
