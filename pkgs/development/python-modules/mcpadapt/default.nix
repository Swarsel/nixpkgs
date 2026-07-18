{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  crewai,
  hatchling,
  jsonref,
  langchain,
  langchain-anthropic,
  langgraph,
  llama-index,
  mcp,
  pytest-asyncio,
  pytestCheckHook,
  python-dotenv,
  smolagents,
  soundfile,
  torchaudio,
}:

buildPythonPackage (finalAttrs: {
  pname = "mcpadapt";
  version = "0.1.20";

  src = fetchFromGitHub {
    owner = "grll";
    repo = "mcpadapt";
    tag = "v${finalAttrs.version}";
    hash = "sha256-mUwGKr+QBkqMKhfEEIlF/jZDW7enKYdngNIoxG5hMU4=";
  };

  # Circular dependency smolagents
  doCheck = false;
  build-system = [ hatchling ];

  dependencies = [
    jsonref
    mcp
    python-dotenv
  ];

  optional-dependencies = {
    audio = [
      torchaudio
      soundfile
    ];

    crewai = [ crewai ];

    langchain = [
      langchain
      langchain-anthropic
      langgraph
    ];

    llamaindex = [ llama-index ];
    smolagents = [ smolagents ];
  };

  pyproject = true;
  pythonImportsCheck = [ "mcpadapt" ];

  meta = {
    description = "MCP servers tool";
    homepage = "https://github.com/grll/mcpadapt";
    changelog = "https://github.com/grll/mcpadapt/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ fab ];
  };
})
