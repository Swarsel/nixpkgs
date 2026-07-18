{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  falcon,
  furl,
  hatchling,
  jsonschema,
  pytest-asyncio,
  pytest-httpbin,
  pytest-pook,
  pytestCheckHook,
  xmltodict,
}:

buildPythonPackage rec {
  pname = "pook";
  version = "2.1.6";

  src = fetchFromGitHub {
    owner = "h2non";
    repo = "pook";
    tag = "v${version}";
    hash = "sha256-pStAlxhyZ1eDER17yLYc1r+kGpEZFW+mi0y3nrPA1CQ=";
  };

  nativeCheckInputs = [
    falcon
    pytest-asyncio
    pytest-httpbin
    pytest-pook
    pytestCheckHook
  ];

  # Tests use sockets
  __darwinAllowLocalNetworking = true;
  build-system = [ hatchling ];

  dependencies = [
    furl
    jsonschema
    xmltodict
  ];

  disabledTestPaths = [
    # Don't test integrations
    "tests/integration/"
    # Tests require network access
    "tests/unit/interceptors/"
  ];

  disabledTests = [
    # furl compat issue
    "test_headers_not_matching"
  ];

  pyproject = true;
  pythonImportsCheck = [ "pook" ];

  meta = {
    description = "HTTP traffic mocking and testing";
    homepage = "https://github.com/h2non/pook";
    changelog = "https://github.com/h2non/pook/blob/${src.tag}/History.rst";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ fab ];
  };
}
