{
  lib,
  fetchFromGitHub,
  # dependencies
  aiohttp,
  aresponses,
  attrs,
  buildPythonPackage,
  jsonpatch,
  looptime,
  pytest-asyncio,
  # tests
  pytestCheckHook,
  # build-system
  setuptools,
  setuptools-scm,
  typing-extensions,
  yarl,
}:

buildPythonPackage (finalAttrs: {
  pname = "kmock";
  version = "0.6";

  src = fetchFromGitHub {
    owner = "nolar";
    repo = "kmock";
    tag = finalAttrs.version;
    hash = "sha256-qpRuSWwaPEgfE+wN1ADSyn2AbXPDzZfZ7dOf8Vw0zJA=";
  };

  nativeCheckInputs = [
    pytestCheckHook
    pytest-asyncio
    aresponses
    looptime
  ];

  __darwinAllowLocalNetworking = true;

  build-system = [
    setuptools
    setuptools-scm
  ];

  dependencies = [
    aiohttp
    attrs
    jsonpatch
    yarl
    typing-extensions
  ];

  disabledTests = [
    # Could not contact DNS servers
    "test_bare_host_resolution"
    # Cannot connect to host clients3.google.com
    "test_hostname_interception"
    # Timeout
    "test_arbitrary_stream"
    "test_kubernetes_watch_stream"
    # assert 0 == 1
    "test_sync_condition_notifying"
  ];

  pyproject = true;
  pythonImportsCheck = [ "kmock" ];

  meta = {
    description = "HTTP/API/Kubernetes Mock Server in Python";
    homepage = "https://github.com/nolar/kmock";
    changelog = "https://github.com/nolar/kmock/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ sigmanificient ];
  };
})
