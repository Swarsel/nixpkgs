{
  lib,
  fetchFromGitHub,
  # dependencies
  anyio,
  # optional dependencies
  brotli,
  brotlicffi,
  buildPythonPackage,
  certifi,
  # tests
  chardet,
  click,
  h2,
  hatch-fancy-pypi-readme,
  # build-system
  hatchling,
  httpcore2,
  # reverse deps
  httpx2,
  idna,
  isPyPy,
  pygments,
  pytest-trio,
  pytestCheckHook,
  pythonOlder,
  rich,
  socksio,
  trustme,
  uv-dynamic-versioning,
  uvicorn,
  zstandard,
}:

buildPythonPackage (finalAttrs: {
  pname = "httpx2";
  version = "2.4.0";

  src = fetchFromGitHub {
    owner = "pydantic";
    repo = "httpx2";
    tag = "v${finalAttrs.version}";
    hash = "sha256-T5As4cdZRHkWszzaDZX8G8Z35TkaBsB/oy92FtOhuBY=";
  };

  postPatch = ''
    pushd src/httpx2
  '';

  nativeCheckInputs = [
    chardet
    pytestCheckHook
    # pytest-httpbin
    pytest-trio
    trustme
    uvicorn
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
    anyio
    certifi
    httpcore2
    idna
  ];

  disabledTests = [
    # network access
    "test_async_proxy_close"
    "test_sync_proxy_close"
  ];

  optional-dependencies = {
    brotli = if isPyPy then [ brotlicffi ] else [ brotli ];

    cli = [
      click
      pygments
      rich
    ];

    http2 = [ h2 ];
    socks = [ socksio ];
    zstd = lib.optionals (pythonOlder "3.14") [ zstandard ];
  };

  pyproject = true;
  pytestFlags = [ "tests/httpx2" ];

  pythonImportsCheck = [
    "httpx2"
  ];

  passthru.tests = {
    inherit httpx2;
  };

  meta = {
    description = "A next generation HTTP client for Python";
    homepage = "https://github.com/pydantic/httpx2";
    changelog = "https://github.com/pydantic/httpx2/blob/${finalAttrs.src.tag}/src/httpx2/CHANGELOG.md";
    license = lib.licenses.bsd3;
    maintainers = with lib.maintainers; [ hexa ];
  };
})
