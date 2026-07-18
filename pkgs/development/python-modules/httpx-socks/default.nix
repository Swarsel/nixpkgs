{
  lib,
  fetchFromGitHub,
  async-timeout,
  buildPythonPackage,
  flask,
  httpcore,
  httpx,
  hypercorn,
  pytest-asyncio,
  pytest-trio,
  pytestCheckHook,
  python-socks,
  setuptools,
  starlette,
  tiny-proxy,
  trio,
  trustme,
  yarl,
}:

buildPythonPackage rec {
  pname = "httpx-socks";
  version = "0.11.0";

  src = fetchFromGitHub {
    owner = "romis2012";
    repo = "httpx-socks";
    tag = "v${version}";
    hash = "sha256-/8nz/5LqEuSr8A8/BWzJM9vHuum6fOYIS2rozr4Omi4=";
  };

  nativeCheckInputs = [
    flask
    hypercorn
    pytest-asyncio
    pytest-trio
    pytestCheckHook
    starlette
    tiny-proxy
    trustme
    yarl
  ];

  __darwinAllowLocalNetworking = true;
  build-system = [ setuptools ];

  dependencies = [
    httpx
    httpcore
    python-socks
  ];

  disabledTests = [
    # Tests don't work in the sandbox
    "test_proxy"
    "test_secure_proxy"
  ];

  optional-dependencies = {
    asyncio = [ async-timeout ];
    trio = [ trio ];
  };

  pyproject = true;
  pythonImportsCheck = [ "httpx_socks" ];

  meta = {
    description = "Proxy (HTTP, SOCKS) transports for httpx";
    homepage = "https://github.com/romis2012/httpx-socks";
    changelog = "https://github.com/romis2012/httpx-socks/releases/tag/${src.tag}";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ fab ];
  };
}
