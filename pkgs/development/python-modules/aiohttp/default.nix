{
  lib,
  stdenv,
  fetchFromGitHub,
  # optional dependencies
  aiodns,
  # dependencies
  aiohappyeyeballs,
  aiosignal,
  async-timeout,
  attrs,
  backports-zstd,
  # tests
  blockbuster,
  brotli,
  brotlicffi,
  buildPythonPackage,
  # build-system
  cython,
  freezegun,
  frozenlist,
  gunicorn,
  isPyPy,
  isa-l,
  isal,
  # native dependencies
  llhttp,
  multidict,
  pkgconfig,
  propcache,
  proxy-py,
  pytest-codspeed,
  pytest-cov-stub,
  pytest-mock,
  pytest-timeout,
  pytest-xdist,
  pytestCheckHook,
  pythonOlder,
  re-assert,
  replaceVars,
  setuptools,
  trustme,
  yarl,
  zlib-ng,
}:

buildPythonPackage (finalAttrs: {
  pname = "aiohttp";
  version = "3.14.1";

  src = fetchFromGitHub {
    owner = "aio-libs";
    repo = "aiohttp";
    tag = "v${finalAttrs.version}";
    hash = "sha256-OJSLv/NfVrKESZqNr51FJUzLRz7wLMRdGoNjKC5EhlI=";
  };

  postPatch = ''
    rm -r vendor
    patchShebangs tools
    touch .git  # tools/gen.py uses .git to find the project root

    # don't install Cython using pip
    substituteInPlace Makefile \
      --replace-fail "cythonize: .install-cython" "cythonize:"

    # don't depend on coverage for tests
    substituteInPlace setup.cfg \
      --replace-fail "ignore:Couldn't import C tracer:coverage.exceptions.CoverageWarning" ""
  '';

  buildInputs = [
    llhttp
  ];

  env.AIOHTTP_USE_SYSTEM_DEPS = true;

  preBuild = ''
    make cythonize
  '';

  nativeCheckInputs = [
    blockbuster
    freezegun
    gunicorn
    # broken on aarch64-darwin
    (if lib.meta.availableOn stdenv.hostPlatform isa-l then isal else null)
    proxy-py
    pytest-codspeed
    pytest-cov-stub
    pytest-mock
    pytest-timeout
    pytest-xdist
    pytestCheckHook
    re-assert
    trustme
    zlib-ng
  ];

  preCheck = ''
    # aiohttp in current folder shadows installed version
    rm -r aiohttp
    touch tests/data.unknown_mime_type # has to be modified after 1 Jan 1990

    export HOME=$(mktemp -d)
  ''
  + lib.optionalString stdenv.hostPlatform.isDarwin ''
    # Work around "OSError: AF_UNIX path too long"
    export TMPDIR="/tmp"
  '';

  __darwinAllowLocalNetworking = true;

  build-system = [
    cython
    pkgconfig
    setuptools
  ];

  dependencies = [
    aiohappyeyeballs
    aiosignal
    attrs
    frozenlist
    multidict
    propcache
    yarl
  ]
  ++ finalAttrs.passthru.optional-dependencies.speedups;

  disabledTests = [
    # Disable tests that require network access
    "test_client_session_timeout_zero"
    "test_mark_formdata_as_processed"
    "test_requote_redirect_url_default"
    "test_tcp_connector_ssl_shutdown_timeout_nonzero_passed"
    "test_tcp_connector_ssl_shutdown_timeout_zero_not_passed"
    "test_invalid_idna"
    # don't run benchmarks
    "test_import_time"
    "test_cookie_pattern_performance"
    "test_forwarded_re_performance"
    "test_regex_performance"
    # racy
    "test_uvloop_secure_https_proxy"
    # Cannot connect to host example.com:443 ssl:default [Could not contact DNS servers]
    "test_tcp_connector_ssl_shutdown_timeout_passed_to_create_connection"
    # Fails with http.cookies.CookieError: Control characters are not allowed in cookies
    "test_parse_set_cookie_headers_uses_unquote_with_octal"
  ]
  ++ lib.optionals stdenv.hostPlatform.is32bit [ "test_cookiejar" ]
  ++ lib.optionals stdenv.hostPlatform.isDarwin [
    "test_addresses" # https://github.com/aio-libs/aiohttp/issues/3572, remove >= v4.0.0
    "test_close"
  ];

  optional-dependencies.speedups = [
    aiodns
    (if isPyPy then brotlicffi else brotli)
  ]
  ++ lib.optionals (pythonOlder "3.14") [
    backports-zstd
  ];

  pyproject = true;

  meta = {
    description = "Asynchronous HTTP Client/Server for Python and asyncio";
    homepage = "https://github.com/aio-libs/aiohttp";
    changelog = "https://docs.aiohttp.org/en/${finalAttrs.src.tag}/changes.html";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ dotlambda ];
  };
})
