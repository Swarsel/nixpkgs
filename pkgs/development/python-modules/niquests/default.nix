{
  lib,
  stdenv,
  fetchFromGitHub,
  aiofiles,
  buildPythonPackage,
  charset-normalizer,
  cryptography,
  fastapi,
  hatchling,
  orjson,
  pytest-asyncio,
  pytest-httpbin,
  pytestCheckHook,
  urllib3-future,
  wassima,
}:

buildPythonPackage rec {
  pname = "niquests";
  version = "3.20.0";

  src = fetchFromGitHub {
    owner = "jawah";
    repo = "niquests";
    tag = "v${version}";
    hash = "sha256-9zBo59l/zDIMKnYX1jOMOCec+oRnCkqJjjJmjbAzoPM=";
  };

  nativeCheckInputs = [
    aiofiles
    cryptography
    fastapi
    pytest-asyncio
    pytest-httpbin
    pytestCheckHook
  ]
  ++ optional-dependencies.socks;

  build-system = [ hatchling ];

  dependencies = [
    charset-normalizer
    urllib3-future
    wassima
  ];

  disabledTestPaths = [
    # tests connect to the internet
    "tests/test_requests.py"
  ]
  ++ lib.optionals stdenv.hostPlatform.isDarwin [
    # NameResolutionError: Failed to resolve 'localhost'
    "tests/test_rate_limiters.py"
    "tests/test_lowlevel.py"
    "tests/test_testserver.py"
    # ssl.SSLCertVerificationError: [SSL: CERTIFICATE_VERIFY_FAILED] certificate verify failed: unable to get local issuer certificate (_ssl.c:1032)
    "tests/test_crl.py"
    "tests/test_live.py"
    "tests/test_ocsp.py"
    "tests/test_sse.py"
  ];

  disabledTests =
    lib.optionals stdenv.hostPlatform.isLinux [
      "test_docker_version_info"
      "test_docker_404_unknown_path"
    ]
    ++ lib.optionals stdenv.hostPlatform.isDarwin [
      # PermissionError: [Errno 1] Operation not permitted
      "test_use_proxy_from_environment"
    ];

  optional-dependencies = {
    inherit (urllib3-future.optional-dependencies)
      brotli
      socks
      ws
      zstd
      ;

    full = [
      orjson
    ]
    ++ urllib3-future.optional-dependencies.brotli
    ++ urllib3-future.optional-dependencies.socks
    ++ urllib3-future.optional-dependencies.qh3
    ++ urllib3-future.optional-dependencies.ws
    ++ urllib3-future.optional-dependencies.zstd;

    http3 = urllib3-future.optional-dependencies.qh3;
    ocsp = urllib3-future.optional-dependencies.qh3;

    speedups = [
      orjson
    ]
    ++ urllib3-future.optional-dependencies.brotli
    ++ urllib3-future.optional-dependencies.zstd;
  };

  pyproject = true;
  pythonImportsCheck = [ "niquests" ];

  meta = {
    description = "Simple HTTP library that is a drop-in replacement for Requests";
    homepage = "https://github.com/jawah/niquests";
    changelog = "https://github.com/jawah/niquests/blob/${src.tag}/HISTORY.md";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ dotlambda ];
  };
}
