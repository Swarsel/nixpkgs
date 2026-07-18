{
  lib,
  fetchFromGitHub,
  addBinToPathHook,
  buildPythonPackage,
  certifi,
  cffi,
  charset-normalizer,
  cryptography,
  curl-impersonate,
  fastapi,
  httpx,
  litestar,
  proxy-py,
  pytest-asyncio,
  pytest-trio,
  pytestCheckHook,
  python-multipart,
  rich,
  setuptools,
  trustme,
  uvicorn,
  websockets,
  writableTmpDirAsHomeHook,
}:
buildPythonPackage rec {
  pname = "curl-cffi";
  version = "0.15.0";

  src = fetchFromGitHub {
    owner = "lexiforest";
    repo = "curl_cffi";
    tag = "v${version}";
    hash = "sha256-I8rQj28IvLD7HWuog46E0dLFgnWSA6oE4Jyn9Flr7mQ=";
  };

  patches = [ ./use-system-libs.patch ];
  buildInputs = [ curl-impersonate ];

  nativeCheckInputs = [
    addBinToPathHook
    charset-normalizer
    cryptography
    fastapi
    httpx
    litestar
    proxy-py
    pytest-asyncio
    pytest-trio
    pytestCheckHook
    python-multipart
    trustme
    uvicorn
    websockets
    writableTmpDirAsHomeHook
  ];

  preCheck = ''
    # import from $out
    rm -r curl_cffi
  '';

  __darwinAllowLocalNetworking = true;

  build-system = [
    cffi
    setuptools
  ];

  dependencies = [
    cffi
    certifi
    rich
  ];

  disabledTestPaths = [
    # test accesses network
    "tests/unittest/test_smoke.py::test_async"
    # Hangs the build (possibly forever) under websockets > 12
    # https://github.com/lexiforest/curl_cffi/issues/657
    "tests/unittest/test_websockets.py::test_websocket"
    # Runs out of memory while testing
    "tests/unittest/test_websockets.py::test_receive_large_messages_run_forever"
    # Fails on high core-count machines (including x86_64)
    "tests/unittest/test_websockets.py::on_message"
    "tests/unittest/test_websockets.py::test_on_data_callback"
    "tests/unittest/test_websockets.py::test_hello_twice_async"
  ];

  disabledTests = [
    # FIXME ImpersonateError: Impersonating chrome136 is not supported
    "test_impersonate_without_version"
    "test_with_impersonate"
    # Impersonating chrome142 is not supported
    "test_cli"
    # InvalidURL: Invalid URL component 'path'
    "test_update_params"
    # tests access network
    "test_add_handle"
    "test_socket_action"
    "test_without_impersonate"
  ];

  enabledTestPaths = [
    "tests/unittest"
  ];

  pyproject = true;
  pythonImportsCheck = [ "curl_cffi" ];

  meta = {
    description = "Python binding for curl-impersonate via cffi";
    homepage = "https://curl-cffi.readthedocs.io";
    changelog = "https://github.com/lexiforest/curl_cffi/releases/tag/${src.tag}";
    license = lib.licenses.mit;

    maintainers = with lib.maintainers; [
      chuangzhu
      sarahec
    ];
  };
}
