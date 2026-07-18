{
  lib,
  aiohttp,
  aiohttp-oauthlib,
  aioresponses,
  aiostream,
  buildPythonPackage,
  click,
  click-log,
  fetchPypi,
  fetchpatch,
  hypothesis,
  nixosTests,
  pytest-asyncio,
  pytest-cov-stub,
  pytestCheckHook,
  requests,
  setuptools,
  setuptools-scm,
  trustme,
  versionCheckHook,
}:

buildPythonPackage (finalAttrs: {
  pname = "vdirsyncer";
  version = "0.20.0";

  src = fetchPypi {
    inherit (finalAttrs) pname version;
    hash = "sha256-/rGlM1AKlcFP0VVzOhBW/jWRklU9gsB8a6BPy/xAsS0=";
  };

  nativeCheckInputs = [
    hypothesis
    pytestCheckHook
    pytest-cov-stub
    pytest-asyncio
    trustme
    aioresponses
  ];

  preCheck = ''
    export DETERMINISTIC_TESTS=true
  '';

  nativeInstallCheckInputs = [
    versionCheckHook
  ];

  build-system = [
    setuptools
    setuptools-scm
  ];

  dependencies = [
    click
    click-log
    requests
    aiostream
    aiohttp
  ];

  disabledTests = [
    "test_create_collections" # Flaky test exceeds deadline on hydra: https://github.com/pimutils/vdirsyncer/issues/837
    "test_request_ssl"
    "test_verbosity"
  ];

  optional-dependencies = {
    google = [ aiohttp-oauthlib ];
  };

  pyproject = true;

  passthru.tests = {
    inherit (nixosTests) vdirsyncer;
  };

  meta = {
    description = "Synchronize calendars and contacts";
    homepage = "https://github.com/pimutils/vdirsyncer";
    changelog = "https://github.com/pimutils/vdirsyncer/blob/v${finalAttrs.version}/CHANGELOG.rst";
    license = lib.licenses.bsd3;
    maintainers = with lib.maintainers; [ stephen-huan ];
    mainProgram = "vdirsyncer";
  };
})
