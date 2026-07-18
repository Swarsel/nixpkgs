{
  lib,
  fetchFromGitHub,
  accelerate,
  buildPythonPackage,
  docling,
  hatchling,
  httpx,
  llama-index,
  llama-index-core,
  llama-index-embeddings-huggingface,
  llama-index-embeddings-openai,
  llama-index-llms-openai-like,
  llama-index-node-parser-docling,
  llama-index-readers-docling,
  llama-index-readers-file,
  llama-index-vector-stores-milvus,
  llama-stack-client,
  mcp,
  ollama,
  pydantic,
  pydantic-settings,
  pytest-asyncio,
  pytestCheckHook,
  python-dotenv,
  smolagents,
  torch,
  transformers,
}:

buildPythonPackage rec {
  pname = "docling-mcp";
  version = "1.3.3";

  src = fetchFromGitHub {
    owner = "docling-project";
    repo = "docling-mcp";
    tag = "v${version}";
    hash = "sha256-OyLL8g9fh1H9N3i5ok885IzC5pFckMoqsjd8oX/HdRY=";
  };

  nativeCheckInputs = [
    pytest-asyncio
    pytestCheckHook
  ];

  build-system = [ hatchling ];

  dependencies = [
    docling
    httpx
    mcp
    pydantic
    pydantic-settings
    python-dotenv
  ];

  disabledTestPaths = [
    # Tests require network access
    "tests/test_mcp_server.py"
    "tests/test_conversion_tools.py"
  ];

  optional-dependencies = {
    llama-index-rag = [
      llama-index
      llama-index-core
      llama-index-embeddings-huggingface
      llama-index-embeddings-openai
      llama-index-llms-openai-like
      llama-index-node-parser-docling
      llama-index-readers-docling
      llama-index-readers-file
      llama-index-vector-stores-milvus
    ];

    llama-stack = [ llama-stack-client ];

    smolagents = [
      accelerate
      ollama
      smolagents
      torch
      transformers
    ];
  };

  pyproject = true;
  pythonImportsCheck = [ "docling_mcp" ];

  pythonRemoveDeps = [
    # Disabled due to circular dependency
    "mellea"
  ];

  meta = {
    description = "Making docling agentic through MCP";
    homepage = "https://github.com/docling-project/docling-mcp";
    changelog = "https://github.com/docling-project/docling-mcp/blob/${src.tag}/CHANGELOG.md";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ fab ];
  };
}
