{
  lib,
  fetchFromGitHub,
  anyio,
  buildPythonPackage,
  # dependencies
  h11,
  # optional dependencies
  h2,
  hatch-fancy-pypi-readme,
  # build-system
  hatchling,
  # reverse deps
  httpx2,
  pytest-httpbin,
  pytest-trio,
  # tests
  pytestCheckHook,
  socksio,
  trio,
  truststore,
  uv-dynamic-versioning,
}:

buildPythonPackage (finalAttrs: {
  pname = "httpcore2";
  version = "2.4.0";

  src = fetchFromGitHub {
    owner = "pydantic";
    repo = "httpx2";
    tag = "v${finalAttrs.version}";
    hash = "sha256-T5As4cdZRHkWszzaDZX8G8Z35TkaBsB/oy92FtOhuBY=";
  };

  postPatch = ''
    pushd src/httpcore2
  '';

  nativeCheckInputs = [
    pytestCheckHook
    pytest-httpbin
    pytest-trio
  ]
  ++ lib.concatAttrValues finalAttrs.passthru.optional-dependencies;

  preCheck = ''
    popd
  '';

  __darwinAllowLocalNetworking = true;
  __structuredAttrs = true;

  build-system = [
    hatchling
    hatch-fancy-pypi-readme
    uv-dynamic-versioning
  ];

  dependencies = [
    h11
    truststore
  ];

  optional-dependencies = {
    asyncio = [ anyio ];
    http2 = [ h2 ];
    socks = [ socksio ];
    trio = [ trio ];
  };

  pyproject = true;
  pytestFlags = [ "tests/httpcore2" ];

  pythonImportsCheck = [
    "httpcore2"
  ];

  passthru.tests = {
    inherit httpx2;
  };

  meta = {
    description = "A next generation HTTP client for Python";
    homepage = "https://github.com/pydantic/httpx2";
    changelog = "https://github.com/pydantic/httpx2/blob/${finalAttrs.src.tag}/src/httpcore2/CHANGELOG.md";
    license = lib.licenses.bsd3;
    maintainers = with lib.maintainers; [ hexa ];
  };
})
