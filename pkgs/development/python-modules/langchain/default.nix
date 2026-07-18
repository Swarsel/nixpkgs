{
  lib,
  fetchFromGitHub,
  # tests
  blockbuster,
  buildPythonPackage,
  # passthru
  gitUpdater,
  # build-system
  hatchling,
  # Optional dependencies
  langchain-anthropic,
  langchain-aws,
  langchain-community,
  # dependencies
  langchain-core,
  langchain-deepseek,
  langchain-fireworks,
  langchain-google-genai,
  langchain-groq,
  langchain-huggingface,
  langchain-mistralai,
  langchain-ollama,
  langchain-openai,
  langchain-perplexity,
  langchain-tests,
  langchain-xai,
  langgraph,
  pydantic,
  pytest-asyncio,
  pytest-mock,
  pytest-socket,
  pytest-xdist,
  pytestCheckHook,
  # runtime
  runtimeShell,
  syrupy,
  toml,
}:

buildPythonPackage (finalAttrs: {
  pname = "langchain";
  version = "1.3.11";

  src = fetchFromGitHub {
    owner = "langchain-ai";
    repo = "langchain";
    tag = "langchain==${finalAttrs.version}";
    hash = "sha256-ARLnl+HNsaFW7glyT3CEsNWvp9quvVkCpQvMLxgS2eI=";
  };

  postPatch = ''
    substituteInPlace langchain/agents/middleware/shell_tool.py \
      --replace-fail '"/bin/bash"' '"${runtimeShell}"'
  '';

  nativeCheckInputs = [
    blockbuster
    langchain-tests
    # langchain-openai -- causes recursion error
    pytest-asyncio
    pytest-mock
    pytest-socket
    pytest-xdist
    pytestCheckHook
    syrupy
    toml
  ];

  __darwinAllowLocalNetworking = true;
  __structuredAttrs = true;
  build-system = [ hatchling ];

  dependencies = [
    langchain-core
    langgraph
    pydantic
  ];

  disabledTestPaths = [
    # Their configuration tests don't place nicely with nixpkgs
    "tests/unit_tests/test_pytest_config.py"

    # Timing sensitive tests
    "tests/unit_tests/agents/middleware/implementations/test_model_retry.py"
  ];

  # All pass with sandbox=false
  disabledTests = [
    # Depends on shell's truncation style
    "test_truncation_indicator_present"
    "test_truncation_by_bytes"
    # Depends on the sleep shell command
    "test_timeout_returns_error"
    # Can't see the shell session results when sandboxed
    "test_startup_and_shutdown_commands"
    # Timing sensitive tests
    "test_tool_retry_constant_backoff"
    # AttributeError: 'ImportErrorProfileModel' object has no attribute 'profile'
    # https://github.com/langchain-ai/langchain/issues/36312
    "test_summarization_middleware_missing_profile"
  ];

  # Note: Not testing with optional dependencies due to mutual recursion
  enabledTestPaths = [
    # integration_tests require network access, database access and require `OPENAI_API_KEY`, etc.
    "tests/unit_tests"
  ];

  optional-dependencies = {
    anthropic = [ langchain-anthropic ];
    aws = [ langchain-aws ];
    # azure-ai = [langchain-azure-ai];
    community = [ langchain-community ];
    deepseek = [ langchain-deepseek ];
    fireworks = [ langchain-fireworks ];
    google-genai = [ langchain-google-genai ];
    # google-vertexai = [langchain-google-vertexai];
    groq = [ langchain-groq ];
    huggingface = [ langchain-huggingface ];
    mistralai = [ langchain-mistralai ];
    ollama = [ langchain-ollama ];
    openai = [ langchain-openai ];
    perplexity = [ langchain-perplexity ];
    # together = [langchain-together];
    xai = [ langchain-xai ];
  };

  pyproject = true;

  pytestFlags = [
    "--only-core"
  ];

  pythonImportsCheck = [ "langchain" ];
  sourceRoot = "${finalAttrs.src.name}/libs/langchain_v1";

  passthru = {
    skipBulkUpdate = true;

    updateScript = gitUpdater {
      ignoredVersions = "a|b|dev|rc";
      rev-prefix = "langchain==";
    };
  };

  meta = {
    description = "Building applications with LLMs through composability";
    homepage = "https://github.com/langchain-ai/langchain";
    changelog = "https://github.com/langchain-ai/langchain/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.mit;

    maintainers = with lib.maintainers; [
      natsukium
      sarahec
    ];
  };
})
