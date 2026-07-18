{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  httpx,
  pytest-asyncio,
  pytestCheckHook,
  setuptools,
}:

buildPythonPackage (finalAttrs: {
  pname = "biothings-client";
  version = "0.5.0";

  src = fetchFromGitHub {
    owner = "biothings";
    repo = "biothings_client.py";
    tag = "v${finalAttrs.version}";
    hash = "sha256-SG664xpajbLLTRfqanqYJhKdZqAOXPTDNBcfCAdlZ5M=";
  };

  nativeCheckInputs = [
    pytestCheckHook
    pytest-asyncio
  ];

  build-system = [ setuptools ];
  dependencies = [ httpx ];

  enabledTestPaths = [
    # All other tests make network requests to exercise the API
    "tests/test_async.py::test_generate_async_settings"
    "tests/test_async.py::test_url_protocol"
    "tests/test_async.py::test_async_client_proxy_discovery"
    "tests/test_async_variant.py::test_format_hgvs"
    "tests/test_sync.py::test_generate_settings"
    "tests/test_sync.py::test_url_protocol"
    "tests/test_sync.py::test_client_proxy_discovery"
    "tests/test_variant.py::test_format_hgvs"
  ];

  pyproject = true;
  pythonImportsCheck = [ "biothings_client" ];

  meta = {
    description = "Wrapper to access Biothings.api-based backend services";
    homepage = "https://github.com/biothings/biothings_client.py";
    changelog = "https://github.com/biothings/biothings_client.py/blob/${finalAttrs.src.tag}/CHANGES.txt";
    license = lib.licenses.bsd3;
    maintainers = with lib.maintainers; [ rayhem ];
  };
})
