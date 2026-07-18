{
  lib,
  stdenv,
  fetchFromGitHub,
  # tests
  anthropic,
  attrs,
  buildPythonPackage,
  dataclasses-json,
  # build-system
  hatchling,
  # dependencies
  httpx,
  multipart,
  opentelemetry-sdk,
  orjson,
  pydantic,
  pytest-asyncio,
  pytest-httpx,
  pytest-socket,
  pytest-vcr,
  pytestCheckHook,
  requests,
  requests-toolbelt,
  uuid-utils,
  websockets,
  xxhash,
  zstandard,
}:

buildPythonPackage (finalAttrs: {
  pname = "langsmith";
  version = "0.8.18";

  src = fetchFromGitHub {
    owner = "langchain-ai";
    repo = "langsmith-sdk";
    tag = "v${finalAttrs.version}";
    hash = "sha256-YQ49pg0+RepwlEHtu8GDUpfnXQF3yFiz6ZeRcnHXSWU=";
  };

  nativeCheckInputs = [
    anthropic
    attrs
    dataclasses-json
    multipart
    opentelemetry-sdk
    pytest-asyncio
    pytest-httpx
    pytest-socket
    pytest-vcr
    pytestCheckHook
  ];

  __darwinAllowLocalNetworking = true;
  build-system = [ hatchling ];

  dependencies = [
    httpx
    orjson
    pydantic
    requests
    requests-toolbelt
    uuid-utils
    websockets
    xxhash
    zstandard
  ];

  disabledTestMarks = [
    "flaky"
  ];

  disabledTestPaths = [
    # due to circular import
    "tests/unit_tests/test_client.py"
    "tests/unit_tests/evaluation/test_runner.py"

    # google-adk isn't packaged (and has an enormous number of dependencies)
    "tests/unit_tests/wrappers/test_google_adk.py"

    # strands-agents isn't packaged
    "tests/unit_tests/wrappers/test_strands_agents.py"
  ];

  disabledTests = [
    # due to circular import
    "test_as_runnable"
    "test_as_runnable_batch"
    "test_as_runnable_async"
    "test_as_runnable_async_batch"
  ]
  ++ lib.optionals stdenv.hostPlatform.isDarwin [
    # flaky (timing sensitive)
    "test_refresh_loop_continues_after_500_errors"
  ];

  # evaluation and external tests require OpenAPI key
  # integration tests are all marked flaky
  enabledTestPaths = [
    "tests/unit_tests"
  ];

  pyproject = true;
  pythonImportsCheck = [ "langsmith" ];
  pythonRelaxDeps = [ "orjson" ];
  sourceRoot = "${finalAttrs.src.name}/python";

  meta = {
    description = "Client library to connect to the LangSmith LLM Tracing and Evaluation Platform";
    homepage = "https://github.com/langchain-ai/langsmith-sdk";
    changelog = "https://github.com/langchain-ai/langsmith-sdk/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.mit;

    maintainers = with lib.maintainers; [
      natsukium
      sarahec
    ];

    mainProgram = "langsmith";
  };
})
