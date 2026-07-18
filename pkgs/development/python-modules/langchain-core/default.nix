{
  lib,
  stdenv,
  fetchFromGitHub,
  # tests
  blockbuster,
  buildPythonPackage,
  freezegun,
  # passthru
  gitUpdater,
  grandalf,
  # build-system
  hatchling,
  # dependencies
  jsonpatch,
  langchain-core,
  langchain-protocol,
  langchain-tests,
  langsmith,
  numpy,
  packaging,
  pydantic,
  pytest-asyncio,
  pytest-mock,
  pytest-xdist,
  pytestCheckHook,
  pyyaml,
  syrupy,
  tenacity,
  typing-extensions,
  uuid-utils,
}:

buildPythonPackage (finalAttrs: {
  pname = "langchain-core";
  version = "1.4.8";

  src = fetchFromGitHub {
    owner = "langchain-ai";
    repo = "langchain";
    tag = "langchain-core==${finalAttrs.version}";
    hash = "sha256-fJKr1NlpCujGoVxxqjaEXGOVZO5NH9+71dWHyMuQ2jw=";
  };

  # avoid infinite recursion
  doCheck = false;

  nativeCheckInputs = [
    blockbuster
    freezegun
    grandalf
    langchain-tests
    numpy
    pytest-asyncio
    pytest-mock
    pytest-xdist
    pytestCheckHook
    syrupy
  ];

  __structuredAttrs = true;
  build-system = [ hatchling ];

  dependencies = [
    jsonpatch
    langchain-protocol
    langsmith
    packaging
    pydantic
    pyyaml
    tenacity
    typing-extensions
    uuid-utils
  ];

  disabledTestPaths = [ "tests/unit_tests/runnables/test_runnable_events_v2.py" ];

  disabledTests = [
    # flaky, sometimes fail to strip uuid from AIMessageChunk before comparing to test value
    "test_map_stream"
    # Compares with machine-specific timings
    "test_rate_limit"
    # flaky: assert (1726352133.7419367 - 1726352132.2697523) < 1
    "test_benchmark_model"

    # TypeError: exceptions must be derived from Warning, not <class 'NoneType'>
    "test_chat_prompt_template_variable_names"
    "test_create_model_v2"

    # Comparison with magic strings
    "test_prompt_with_chat_model"
    "test_prompt_with_chat_model_async"
    "test_prompt_with_llm"
    "test_prompt_with_llm_parser"
    "test_prompt_with_llm_and_async_lambda"
    "test_prompt_with_chat_model_and_parser"
    "test_combining_sequences"

    # AssertionError: assert [+ received] == [- snapshot]
    "test_chat_input_schema"
    # AssertionError: assert {'$defs': {'D...ype': 'array'} == {'$defs': {'D...ype': 'array'}
    "test_schemas"
    # AssertionError: assert [+ received] == [- snapshot]
    "test_graph_sequence_map"
    "test_representation_of_runnables"

    # Requires network access
    "test_discord_webhook"
    "test_https_only_mode"
    "test_ngrok_url"
    "test_safe_url_returns_true"
    "test_slack_webhook"
    "test_valid_public_https_url"
    "test_valid_public_http_url"
    "test_valid_url_accepted"
    "test_webhook_site"
  ]
  ++ lib.optionals stdenv.hostPlatform.isDarwin [
    # Langchain-core the following tests due to the test comparing execution time with magic values.
    "test_queue_for_streaming_via_sync_call"
    "test_same_event_loop"
    # Comparisons with magic numbers
    "test_rate_limit_ainvoke"
    "test_rate_limit_astream"
  ];

  enabledTestPaths = [ "tests/unit_tests" ];
  pyproject = true;
  pythonImportsCheck = [ "langchain_core" ];
  sourceRoot = "${finalAttrs.src.name}/libs/core";

  passthru = {
    # python updater script sets the wrong tag
    skipBulkUpdate = true;

    tests.pytest = langchain-core.overridePythonAttrs (_: {
      doCheck = true;
    });

    updateScript = gitUpdater {
      ignoredVersions = "a|b|dev|rc";
      rev-prefix = "langchain-core==";
    };
  };

  meta = {
    description = "Building applications with LLMs through composability";
    homepage = "https://github.com/langchain-ai/langchain/tree/master/libs/core";
    changelog = "https://github.com/langchain-ai/langchain/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.mit;

    maintainers = with lib.maintainers; [
      natsukium
      sarahec
    ];
  };
})
