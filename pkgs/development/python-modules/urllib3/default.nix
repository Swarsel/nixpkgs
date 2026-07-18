{
  lib,
  fetchFromGitHub,
  # optional-dependencies
  backports-zstd,
  brotli,
  brotlicffi,
  buildPythonPackage,
  h2,
  hatch-vcs,
  # build-system
  hatchling,
  # tests
  httpx,
  isPyPy,
  pyopenssl,
  pysocks,
  pytest-socket,
  pytest-timeout,
  pytestCheckHook,
  quart,
  quart-trio,
  tornado,
  trio,
  trustme,
}:

buildPythonPackage (finalAttrs: {
  pname = "urllib3";
  version = "2.7.0";

  src = fetchFromGitHub {
    owner = "urllib3";
    repo = "urllib3";
    tag = finalAttrs.version;
    hash = "sha256-iN59MS5gKgDxe2v4ILrZ/1y7wV4yB1tFs4ATKppYAAk=";
  };

  # Tests in urllib3 are mostly timeout-based instead of event-based and
  # are therefore inherently flaky. On your own machine, the tests will
  # typically build fine, but on a loaded cluster such as Hydra random
  # timeouts will occur.
  #
  # The urllib3 test suite has two different timeouts in their test suite
  # (see `test/__init__.py`):
  # - SHORT_TIMEOUT
  # - LONG_TIMEOUT
  # When CI is in the env, LONG_TIMEOUT will be significantly increased.
  # Still, failures can occur and for that reason tests are disabled.
  doCheck = false;

  nativeCheckInputs = [
    httpx
    pyopenssl
    pytest-socket
    pytest-timeout
    pytestCheckHook
    quart
    quart-trio
    tornado
    trio
    trustme
  ]
  ++ lib.concatAttrValues finalAttrs.passthru.optional-dependencies;

  preCheck = ''
    export CI # Increases LONG_TIMEOUT
  '';

  build-system = [
    hatchling
    hatch-vcs
  ];

  disabledTestMarks = [
    "requires_network"
  ];

  optional-dependencies = {
    brotli = if isPyPy then [ brotlicffi ] else [ brotli ];
    h2 = [ h2 ];
    socks = [ pysocks ];
    zstd = [ backports-zstd ];
  };

  pyproject = true;
  pythonImportsCheck = [ "urllib3" ];

  passthru.tests.pytest = finalAttrs.finalPackage.overrideAttrs (_: {
    doInstallCheck = true;
  });

  meta = {
    description = "Powerful, user-friendly HTTP client for Python";
    homepage = "https://github.com/urllib3/urllib3";
    changelog = "https://github.com/urllib3/urllib3/blob/${finalAttrs.src.tag}/CHANGES.rst";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ fab ];
  };
})
