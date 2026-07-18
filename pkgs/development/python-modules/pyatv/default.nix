{
  lib,
  stdenv,
  fetchFromGitHub,
  aiohttp,
  async-timeout,
  buildPythonPackage,
  chacha20poly1305-reuseable,
  cryptography,
  deepdiff,
  ifaddr,
  miniaudio,
  protobuf,
  pydantic,
  pyfakefs,
  pytest-aiohttp,
  pytest-asyncio_0,
  pytest-httpserver,
  pytest-timeout,
  pytestCheckHook,
  pythonAtLeast,
  requests,
  setuptools,
  srptools,
  tabulate,
  tinytag,
  zeroconf,
}:

buildPythonPackage (finalAttrs: {
  pname = "pyatv";
  version = "0.18.0";

  src = fetchFromGitHub {
    owner = "postlund";
    repo = "pyatv";
    tag = "v${finalAttrs.version}";
    hash = "sha256-UNBpVB2H+xr0ijdlfK/Hrh6k3lhRSqHkthjWp/WZsaQ=";
  };

  nativeCheckInputs = [
    deepdiff
    pyfakefs
    (pytest-aiohttp.override { pytest-asyncio = pytest-asyncio_0; })
    pytest-asyncio_0
    pytest-httpserver
    pytest-timeout
    pytestCheckHook
  ];

  __darwinAllowLocalNetworking = true;
  build-system = [ setuptools ];

  dependencies = [
    aiohttp
    async-timeout
    chacha20poly1305-reuseable
    cryptography
    ifaddr
    miniaudio
    protobuf
    pydantic
    requests
    srptools
    tabulate
    tinytag
    zeroconf
  ];

  disabledTestPaths = [
    # Test doesn't work in the sandbox
    "tests/protocols/companion/test_companion_auth.py"
    "tests/protocols/mrp/test_mrp_auth.py"
  ];

  disabledTests =
    lib.optionals (pythonAtLeast "3.12") [
      # https://github.com/postlund/pyatv/issues/2365
      "test_simple_dispatch"
    ]
    ++ lib.optionals (stdenv.hostPlatform.isDarwin) [
      # tests/protocols/raop/test_raop_functional.py::test_stream_retransmission[raop_properties2-2-True] - assert False
      "test_stream_retransmission"
    ];

  pyproject = true;
  pythonImportsCheck = [ "pyatv" ];

  pythonRelaxDeps = [
    "aiohttp"
    "async_timeout"
    "bitarray"
    "chacha20poly1305-reuseable"
    "cryptography"
    "ifaddr"
    "miniaudio"
    "protobuf"
    "requests"
    "srptools"
    "zeroconf"
  ];

  meta = {
    description = "Python client library for the Apple TV";
    homepage = "https://github.com/postlund/pyatv";
    changelog = "https://github.com/postlund/pyatv/blob/${finalAttrs.src.tag}/CHANGES.md";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ fab ];
  };
})
