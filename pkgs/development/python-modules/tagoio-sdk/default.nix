{
  lib,
  fetchFromGitHub,
  aiohttp,
  buildPythonPackage,
  hatchling,
  pytestCheckHook,
  python-dateutil,
  python-socketio,
  requests,
  requests-mock,
  requests-toolbelt,
  sseclient-py,
}:

buildPythonPackage (finalAttrs: {
  pname = "tagoio-sdk";
  version = "5.1.2";

  src = fetchFromGitHub {
    owner = "tago-io";
    repo = "sdk-python";
    tag = "v${finalAttrs.version}";
    hash = "sha256-PwybHVls5TDqCj/S2LOc8ZNIIg8DyaFZJnutKy0v+2w=";
  };

  nativeCheckInputs = [
    requests-mock
    pytestCheckHook
  ];

  build-system = [ hatchling ];

  dependencies = [
    aiohttp
    python-dateutil
    python-socketio
    requests
    requests-toolbelt
    sseclient-py
  ];

  pyproject = true;
  pythonImportsCheck = [ "tagoio_sdk" ];
  pythonRelaxDeps = [ "requests" ];

  meta = {
    description = "Module for interacting with Tago.io";
    homepage = "https://github.com/tago-io/sdk-python";
    changelog = "https://github.com/tago-io/sdk-python/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ fab ];
  };
})
