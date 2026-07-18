{
  lib,
  stdenv,
  fetchFromGitHub,
  buildPythonPackage,
  # dependencies
  pycryptodome,
  # tests
  pytestCheckHook,
  requests,
  # build-system
  setuptools,
  urllib3,
  websocket-client,
}:

buildPythonPackage (finalAttrs: {
  pname = "ibind";
  version = "0.1.22";

  src = fetchFromGitHub {
    owner = "Voyz";
    repo = "ibind";
    tag = "v${finalAttrs.version}";
    hash = "sha256-hFjxkAEbhbcwseI7XwrEBtq5kzGj6XRBw3mqcxar9r0=";
  };

  # ModuleNotFoundError: No module named 'test_utils'
  # TODO: The fix is already merged upstream: remove when updating to the next release
  postPatch = ''
    substituteInPlace "pytest.ini" \
      --replace-fail '[tool:pytest]' '[pytest]'
  '';

  strictDeps = true;

  nativeCheckInputs = [
    pytestCheckHook
  ];

  __structuredAttrs = true;

  build-system = [
    setuptools
  ];

  dependencies = [
    pycryptodome
    requests
    urllib3
    websocket-client
  ];

  disabledTests = lib.optionals stdenv.hostPlatform.isDarwin [
    # AssertionError: 0.2564859390258789 != 0.1 within 0.02 delta (0.1564859390258789 difference)
    "test_wait_until_timeout"
  ];

  # Otherwise, fails with:
  # __main__.py: error: unrecognized arguments: unpacked/ibind-0.0.2
  postUnpack = ''
    rm -r "$sourceRoot/dist"
  '';

  pyproject = true;
  pythonImportsCheck = [ "ibind" ];

  pythonRelaxDeps = [
    "requests"
    "websocket-client"
  ];

  meta = {
    description = "REST and WebSocket client library for Interactive Brokers Client Portal Web API";
    homepage = "https://github.com/Voyz/ibind";
    changelog = "https://github.com/Voyz/ibind/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ GaetanLepage ];
  };
})
