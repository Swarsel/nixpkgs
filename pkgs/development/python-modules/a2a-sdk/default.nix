{
  lib,
  stdenv,
  fetchFromGitHub,
  aiosqlite,
  buildPythonPackage,
  cryptography,
  fastapi,
  google-api-core,
  grpcio,
  grpcio-reflection,
  grpcio-tools,
  hatchling,
  httpx,
  httpx-sse,
  opentelemetry-api,
  opentelemetry-sdk,
  protobuf,
  pydantic,
  pyjwt,
  pytest-asyncio,
  pytest-cov-stub,
  pytest-timeout,
  pytest-xdist,
  pytestCheckHook,
  pythonAtLeast,
  respx,
  sqlalchemy,
  sse-starlette,
  starlette,
  uv-dynamic-versioning,
  uvicorn,
}:

buildPythonPackage (finalAttrs: {
  pname = "a2a-sdk";
  version = "0.3.26";

  src = fetchFromGitHub {
    owner = "a2aproject";
    repo = "a2a-python";
    tag = "v${finalAttrs.version}";
    hash = "sha256-OQVNoKCx/7t3LeLgcVCVJUDnrWnugbM6EReE0713CM4=";
  };

  nativeCheckInputs = [
    aiosqlite
    pytest-asyncio
    pytest-cov-stub
    pytest-timeout
    pytest-xdist
    pytestCheckHook
    respx
    uvicorn
  ]
  ++ lib.flatten (builtins.attrValues finalAttrs.passthru.optional-dependencies);

  build-system = [
    hatchling
    uv-dynamic-versioning
  ];

  dependencies = [
    google-api-core
    httpx
    httpx-sse
    protobuf
    pydantic
  ];

  disabledTests =
    [ ]
    ++ lib.optionals (pythonAtLeast "3.14") [
      # _pickle.PicklingError: Can't pickle local object <function...
      "test_notification_triggering"
    ]
    ++ lib.optionals stdenv.hostPlatform.isDarwin [
      # AttributeError: Can't get local object 'FastAPI.setup.<locals>.openap…
      "test_notification_triggering_with_in_message_config_e2e"
      "test_notification_triggering_after_config_change_e2e"
      "test_trace_function_sync_attribute_extractor_error_logged"
    ];

  optional-dependencies = {
    encryption = [ cryptography ];

    grpc = [
      grpcio
      grpcio-reflection
      grpcio-tools
    ];

    http-server = [
      fastapi
      sse-starlette
      starlette
    ];

    mysql = [
      sqlalchemy
    ]
    ++ sqlalchemy.optional-dependencies.asyncio
    ++ sqlalchemy.optional-dependencies.postgresql_asyncpg;

    postgresql = [
      sqlalchemy
    ]
    ++ sqlalchemy.optional-dependencies.asyncio
    ++ sqlalchemy.optional-dependencies.postgresql_asyncpg;

    signing = [ pyjwt ];

    sqlite = [
      sqlalchemy
    ]
    ++ sqlalchemy.optional-dependencies.asyncio
    ++ sqlalchemy.optional-dependencies.aiosqlite;

    telemetry = [
      opentelemetry-api
      opentelemetry-sdk
    ];
  };

  pyproject = true;
  pythonImportsCheck = [ "a2a" ];

  meta = {
    description = "Python SDK for the Agent2Agent (A2A) Protocol";
    homepage = "https://github.com/a2aproject/a2a-python";
    changelog = "https://github.com/a2aproject/a2a-python/blob/${finalAttrs.src.tag}/CHANGELOG.md";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ fab ];
  };
})
