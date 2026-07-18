{
  lib,
  fetchFromGitHub,
  # tests
  addBinToPathHook,
  # dependencies
  annotated-types,
  anyio,
  attrs,
  brotli,
  buildPythonPackage,
  click,
  cryptography,
  email-validator,
  # build-system
  hatchling,
  httpx,
  httpx-sse,
  jinja2,
  jsbeautifier,
  litestar-htmx,
  mako,
  minijinja,
  msgspec,
  multidict,
  multipart,
  opentelemetry-instrumentation-asgi,
  piccolo,
  picologging,
  polyfactory,
  prometheus-client,
  pydantic,
  pydantic-extra-types,
  pyjwt,
  pytest-asyncio,
  pytest-lazy-fixtures,
  pytest-mock,
  pytest-rerunfailures,
  pytest-timeout,
  pytest-xdist,
  pytestCheckHook,
  pythonAtLeast,
  pythonOlder,
  pyyaml,
  redis,
  rich,
  rich-click,
  sniffio,
  structlog,
  time-machine,
  trio,
  typing-extensions,
  uvicorn,
  valkey,
  versionCheckHook,
}:

buildPythonPackage (finalAttrs: {
  pname = "litestar";
  version = "2.21.1";

  src = fetchFromGitHub {
    owner = "litestar-org";
    repo = "litestar";
    tag = "v${finalAttrs.version}";
    hash = "sha256-dH51GecYwVTnOO+F1FJnFR2VO3IvLbpKWbxK7jssak8=";
  };

  nativeCheckInputs = [
    addBinToPathHook
    httpx-sse
    pytest-asyncio
    pytest-lazy-fixtures
    pytest-mock
    pytest-rerunfailures
    pytest-timeout
    pytest-xdist
    pytestCheckHook
    time-machine
    trio
    versionCheckHook
  ];

  __darwinAllowLocalNetworking = true;
  build-system = [ hatchling ];

  dependencies = [
    anyio
    click
    httpx
    litestar-htmx
    msgspec
    multidict
    multipart
    polyfactory
    pyyaml
    rich
    rich-click
    sniffio
    typing-extensions
  ];

  disabledTests = [
    # StartupError
    "test_subprocess_async_client"
  ];

  enabledTestPaths = [
    # Follow GitHub CI
    "docs/examples/"
  ];

  optional-dependencies = {
    annotated-types = [ annotated-types ];
    attrs = [ attrs ];
    brotli = [ brotli ];

    cli = [
      jsbeautifier
      uvicorn
    ]
    ++ uvicorn.optional-dependencies.standard;

    cryptography = [ cryptography ];
    jinja = [ jinja2 ];

    jwt = [
      cryptography
      pyjwt
    ];

    mako = [ mako ];
    minijinja = [ minijinja ];
    opentelemetry = [ opentelemetry-instrumentation-asgi ];
    piccolo = [ piccolo ];
    picologging = lib.optionals (pythonOlder "3.13") [ picologging ];
    prometheus = [ prometheus-client ];

    pydantic = [
      pydantic
      email-validator
      pydantic-extra-types
    ];

    redis = [ redis ] ++ redis.optional-dependencies.hiredis;

    # sqlalchemy = [ advanced-alchemy ];
    standard = [
      jinja2
      jsbeautifier
      uvicorn
    ]
    ++ uvicorn.optional-dependencies.standard;

    structlog = [ structlog ];
    valkey = [ valkey ] ++ valkey.optional-dependencies.libvalkey;
  };

  pyproject = true;

  pytestFlags = lib.optionals (pythonAtLeast "3.14") [
    # UserWarning: Core Pydantic V1 functionality isn't compatible with Python 3.14 or greater.
    "-Wignore::UserWarning"
  ];

  versionCheckProgramArg = "version";

  meta = {
    description = "Production-ready, Light, Flexible and Extensible ASGI API framework";
    homepage = "https://litestar.dev/";
    changelog = "https://github.com/litestar-org/litestar/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ bot-wxt1221 ];
    platforms = lib.platforms.unix;
    mainProgram = "litestar";
  };
})
