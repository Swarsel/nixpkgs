{
  lib,
  stdenv,
  fetchFromGitHub,
  # dependencies
  aiohappyeyeballs,
  async-interrupt,
  buildPythonPackage,
  chacha20poly1305-reuseable,
  cryptography,
  # build-system
  cython,
  # tests
  mock,
  noiseprotocol,
  protobuf,
  pytest-asyncio,
  pytestCheckHook,
  setuptools,
  tzdata,
  tzlocal,
  zeroconf,
}:

buildPythonPackage (finalAttrs: {
  pname = "aioesphomeapi";
  version = "45.3.1"; # must track the major version that home-assistant pins

  src = fetchFromGitHub {
    owner = "esphome";
    repo = "aioesphomeapi";
    tag = "v${finalAttrs.version}";
    hash = "sha256-+8P6OL+4Y+qrKLYqXtjBL2ylcamsF24Ccn00Vt9ohD0=";
  };

  postPatch = ''
    substituteInPlace pyproject.toml \
      --replace-fail "setuptools>=82.0.1" setuptools \
      --replace-fail "Cython>=3.2.5" Cython
  '';

  # Lack of network sandboxing leads to conflicting listeners when testing
  # this package e.g. in nixpkgs-review on the two suppoted python package sets.
  doCheck = !stdenv.hostPlatform.isDarwin;

  nativeCheckInputs = [
    mock
    pytest-asyncio
    pytestCheckHook
  ];

  __darwinAllowLocalNetworking = true;

  build-system = [
    setuptools
    cython
  ];

  dependencies = [
    aiohappyeyeballs
    async-interrupt
    chacha20poly1305-reuseable
    cryptography
    noiseprotocol
    protobuf
    tzdata
    tzlocal
    zeroconf
  ];

  disabledTestPaths = [
    # benchmarking requires pytest-codespeed
    "tests/benchmarks"
  ];

  pyproject = true;
  pythonImportsCheck = [ "aioesphomeapi" ];

  pythonRelaxDeps = [
    "aiohappyeyeballs"
    "cryptography"
  ];

  meta = {
    description = "Python Client for ESPHome native API";
    homepage = "https://github.com/esphome/aioesphomeapi";
    changelog = "https://github.com/esphome/aioesphomeapi/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.mit;

    maintainers = with lib.maintainers; [
      fab
      hexa
    ];
  };
})
