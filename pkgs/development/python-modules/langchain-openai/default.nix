{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  # tests
  freezegun,
  # passthru
  gitUpdater,
  # build-system
  hatchling,
  langchain,
  # dependencies
  langchain-core,
  langchain-tests,
  lark,
  openai,
  pandas,
  pytest-asyncio,
  pytest-cov-stub,
  pytest-mock,
  pytest-socket,
  pytestCheckHook,
  requests-mock,
  responses,
  syrupy,
  tiktoken,
  toml,
}:

buildPythonPackage (finalAttrs: {
  pname = "langchain-openai";
  version = "1.3.2";

  src = fetchFromGitHub {
    owner = "langchain-ai";
    repo = "langchain";
    tag = "langchain-openai==${finalAttrs.version}";
    hash = "sha256-VmGbfciQlKBYgyUhFLUVzZaYSpEcK2pRokvsWrFpxaM=";
  };

  nativeCheckInputs = [
    freezegun
    langchain
    langchain-tests
    lark
    pandas
    pytest-asyncio
    pytest-cov-stub
    pytestCheckHook
    pytest-mock
    pytest-socket
    requests-mock
    responses
    syrupy
    toml
  ];

  __structuredAttrs = true;
  build-system = [ hatchling ];

  dependencies = [
    langchain-core
    openai
    tiktoken
  ];

  disabledTests = [
    # These tests require network access
    "test__get_encoding_model"
    "test_chat_openai_get_num_tokens"
    "test_embed_documents_with_custom_chunk_size"
    "test_get_num_tokens_from_messages"
    "test_get_token_ids"
    "test_embeddings_respects_token_limit"

    # Fail when langchain-core gets ahead of this package
    "test_serdes"
    "test_loads_openai_llm"
    "test_load_openai_llm"
    "test_loads_openai_chat"
    "test_load_openai_chat"
    "test_format_message_content"
  ];

  enabledTestPaths = [ "tests/unit_tests" ];
  pyproject = true;
  pythonImportsCheck = [ "langchain_openai" ];
  sourceRoot = "${finalAttrs.src.name}/libs/partners/openai";

  passthru = {
    # python updater script sets the wrong tag
    skipBulkUpdate = true;

    updateScript = gitUpdater {
      ignoredVersions = "a|b|dev|rc";
      rev-prefix = "langchain-openai==";
    };
  };

  meta = {
    description = "Integration package connecting OpenAI and LangChain";
    homepage = "https://github.com/langchain-ai/langchain/tree/master/libs/partners/openai";
    changelog = "https://github.com/langchain-ai/langchain/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.mit;

    maintainers = with lib.maintainers; [
      natsukium
      sarahec
    ];
  };
})
