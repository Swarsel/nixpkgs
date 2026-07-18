{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  # dependencies
  genai-prices,
  griffelib,
  # build-system
  hatchling,
  httpx,
  opentelemetry-api,
  pydantic,
  pydantic-graph,
  typing-inspection,
  uv-dynamic-versioning,
}:

buildPythonPackage (finalAttrs: {
  pname = "pydantic-ai-slim";
  version = "2.8.0";

  src = fetchFromGitHub {
    owner = "pydantic";
    repo = "pydantic-ai";
    tag = "v${finalAttrs.version}";
    hash = "sha256-KwuhRZWGOofglR5SVsUOijtgYnhVV3Fc9DLtUwL+KSU=";
  };

  doCheck = false;

  build-system = [
    hatchling
    uv-dynamic-versioning
  ];

  dependencies = [
    genai-prices
    griffelib
    httpx
    opentelemetry-api
    pydantic-graph
    pydantic
    typing-inspection
  ];

  pyproject = true;

  pythonImportsCheck = [
    "pydantic_ai"
  ];

  sourceRoot = "${finalAttrs.src.name}/pydantic_ai_slim";

  meta = {
    description = "GenAI Agent Framework, the Pydantic way";
    homepage = "https://github.com/pydantic/pydantic-ai";
    changelog = "https://github.com/pydantic/pydantic-ai/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ hexa ];
  };
})
