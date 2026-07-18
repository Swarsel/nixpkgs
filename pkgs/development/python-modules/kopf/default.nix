{
  lib,
  fetchFromGitHub,
  aiohttp,
  aresponses,
  buildPythonPackage,
  certvalidator,
  click,
  freezegun,
  iso8601,
  jsonpatch,
  kmock,
  looptime,
  pyngrok,
  pytest-asyncio,
  pytest-mock,
  pytest-timeout,
  pytestCheckHook,
  python-json-logger,
  pyyaml,
  setuptools,
  setuptools-scm,
}:

buildPythonPackage rec {
  pname = "kopf";
  version = "1.44.5";

  src = fetchFromGitHub {
    owner = "nolar";
    repo = "kopf";
    tag = version;
    hash = "sha256-iwAq06qXtD3c0otC1S9TfRPDpc54y/NJQpJ7X8dCgGI=";
  };

  nativeCheckInputs = [
    pytestCheckHook
    pyngrok
    pytest-timeout
    pytest-asyncio
    pytest-mock
    kmock
    freezegun
    certvalidator
    aresponses
    looptime
  ];

  __darwinAllowLocalNetworking = true;

  build-system = [
    setuptools
    setuptools-scm
  ];

  dependencies = [
    pyyaml
    python-json-logger
    aiohttp
    iso8601
    jsonpatch
    click
  ];

  disabledTestPaths = [
    # Module astpath unavailable in nixpkgs
    "tests/admission/test_certificates.py"
    "tests/e2e/test_examples.py"

    # Module certbuilder unavailable in nixpkgs
    "tests/admission/test_webhook_detection.py"
    "tests/admission/test_webhook_ngrok.py"
    "tests/admission/test_webhook_server.py"
    "tests/authentication/test_credentials.py"
  ];

  disabledTests = [
    # assert [] to due missing certificate
    "test_connection_info_as_ssl_context_when_insecure"
  ];

  pyproject = true;
  pytestFlags = [ "-Wignore::pytest.PytestUnraisableExceptionWarning" ];

  pythonImportsCheck = [
    "kopf"
  ];

  meta = {
    description = "Python framework to write Kubernetes operators";
    homepage = "https://kopf.readthedocs.io/";
    changelog = "https://github.com/nolar/kopf/releases/tag/${src.tag}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ genga898 ];
  };
}
