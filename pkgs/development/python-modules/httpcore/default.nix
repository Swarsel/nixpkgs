{
  lib,
  fetchFromGitHub,
  anyio,
  buildPythonPackage,
  certifi,
  h11,
  h2,
  hatch-fancy-pypi-readme,
  hatchling,
  # for passthru.tests
  httpx,
  httpx-socks,
  pytest-httpbin,
  pytest-trio,
  pytestCheckHook,
  respx,
  socksio,
  trio,
}:

buildPythonPackage rec {
  pname = "httpcore";
  version = "1.0.9";

  src = fetchFromGitHub {
    owner = "encode";
    repo = "httpcore";
    tag = version;
    hash = "sha256-YtAbx0iXN7u8pMBXQBUydvAH6ilH+veklvxSh5EVFXo=";
  };

  nativeCheckInputs = [
    pytest-httpbin
    pytest-trio
    pytestCheckHook
  ]
  ++ lib.concatAttrValues optional-dependencies;

  __darwinAllowLocalNetworking = true;

  build-system = [
    hatchling
    hatch-fancy-pypi-readme
  ];

  dependencies = [
    certifi
    h11
  ];

  optional-dependencies = {
    asyncio = [ anyio ];
    http2 = [ h2 ];
    socks = [ socksio ];
    trio = [ trio ];
  };

  pyproject = true;
  pythonImportsCheck = [ "httpcore" ];

  passthru.tests = {
    inherit httpx httpx-socks respx;
  };

  meta = {
    description = "Minimal low-level HTTP client";
    homepage = "https://github.com/encode/httpcore";
    changelog = "https://github.com/encode/httpcore/blob/${version}/CHANGELOG.md";
    license = lib.licenses.bsd3;
    maintainers = with lib.maintainers; [ ris ];
  };
}
