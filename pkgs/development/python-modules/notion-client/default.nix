{
  lib,
  fetchFromGitHub,
  anyio,
  buildPythonPackage,
  httpx,
  pytest-asyncio,
  pytest-cov-stub,
  pytest-vcr,
  pytestCheckHook,
  setuptools,
}:

buildPythonPackage rec {
  pname = "notion-client";
  version = "2.7.0";

  src = fetchFromGitHub {
    owner = "ramnes";
    repo = "notion-sdk-py";
    tag = version;
    hash = "sha256-15IPycaLk8r0/bUphL+IDypBMhgdX1tAUS50VD3p/00=";
  };

  nativeCheckInputs = [
    anyio
    pytest-asyncio
    pytest-cov-stub
    pytest-vcr
    pytestCheckHook
  ];

  build-system = [ setuptools ];
  dependencies = [ httpx ];

  disabledTests = [
    # Test requires network access
    "test_api_http_response_error"
  ];

  pyproject = true;
  pythonImportsCheck = [ "notion_client" ];

  meta = {
    description = "Python client for the official Notion API";
    homepage = "https://github.com/ramnes/notion-sdk-py";
    changelog = "https://github.com/ramnes/notion-sdk-py/releases/tag/${src.tag}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ jpetrucciani ];
  };
}
