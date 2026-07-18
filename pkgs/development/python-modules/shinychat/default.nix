{
  lib,
  fetchFromGitHub,
  # optional-dependencies
  anthropic,
  buildPythonPackage,
  chatlas,
  google-generativeai,
  # build-system
  hatch-vcs,
  hatchling,
  # dependencies
  htmltools,
  langchain-core,
  ollama,
  openai,
  # tests
  pillow,
  playwright,
  pydantic,
  pytest-playwright,
  pytestCheckHook,
  shiny,
  shinychat,
  tokenizers,
}:

buildPythonPackage rec {
  pname = "shinychat";
  version = "0.3.0";

  src = fetchFromGitHub {
    owner = "posit-dev";
    repo = "shinychat";
    tag = "r/v${version}";
    hash = "sha256-d+wcZuokZ8uH/z/IthH6h2SDD81NJg1cn6+jwYwfcxE=";
  };

  # Circular dependency with shiny
  doCheck = false;

  nativeCheckInputs = [
    pillow
    playwright
    pytest-playwright
    pytestCheckHook
    shiny
  ]
  ++ lib.concatAttrValues optional-dependencies;

  build-system = [
    hatch-vcs
    hatchling
  ];

  dependencies = [
    htmltools
  ];

  disabledTests = [
    # AssertionError: assert False
    "test_as_langchain_message"

    # AssertionError: assert 'AIMessage' == 'BaseMessage'
    "test_langchain_normalization"

    # RuntimeError: Failed to download a default tokenizer
    "test_chat_message_trimming"

    # Require running a headless chromium browser
    "test_latest_stream_result"
    "test_validate_chat"
    "test_validate_chat_append_user_message"
    "test_validate_chat_append_user_message"
    "test_validate_chat_basic"
    "test_validate_chat_basic"
    "test_validate_chat_basic"
    "test_validate_chat_basic_error"
    "test_validate_chat_input_suggestion"
    "test_validate_chat_message_stream_context"
    "test_validate_chat_shiny_output"
    "test_validate_chat_shiny_output"
    "test_validate_chat_stream_result"
    "test_validate_chat_transform"
    "test_validate_chat_transform_assistant"
    "test_validate_chat_transform_assistant"
    "test_validate_chat_update_user_input"
    "test_validate_stream_basic"
    "test_validate_stream_shiny_ui"
  ];

  optional-dependencies = {
    providers = [
      anthropic
      chatlas
      google-generativeai
      langchain-core
      ollama
      openai
      pydantic
      tokenizers
    ];
  };

  pyproject = true;

  pythonImportsCheck = [
    # ImportError: cannot import name 'Chat' from partially initialized module 'shinychat' (most likely due to a circular import)
    # "shinychat"
  ];

  pythonRemoveDeps = [
    "shiny" # circular dependency
  ];

  passthru.tests.pytest = shinychat.overridePythonAttrs {
    doCheck = true;
  };

  meta = {
    description = "Chat UI component for Shiny";
    homepage = "https://posit-dev.github.io/shinychat";
    changelog = "https://github.com/posit-dev/shinychat/releases/tag/${src.tag}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ GaetanLepage ];
    downloadPage = "https://github.com/posit-dev/shinychat";
  };
}
