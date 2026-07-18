{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  # build-system
  hatchling,
  # dependencies
  httpx,
  logfire-api,
  pydantic,
  typing-inspection,
  uv-dynamic-versioning,
}:

buildPythonPackage (finalAttrs: {
  pname = "pydantic-graph";
  version = "2.8.0";

  src = fetchFromGitHub {
    owner = "pydantic";
    repo = "pydantic-ai";
    tag = "v${finalAttrs.version}";
    hash = "sha256-KwuhRZWGOofglR5SVsUOijtgYnhVV3Fc9DLtUwL+KSU=";
  };

  doCheck = false; # no tests

  build-system = [
    hatchling
    uv-dynamic-versioning
  ];

  dependencies = [
    httpx
    logfire-api
    pydantic
    typing-inspection
  ];

  pyproject = true;

  pythonImportsCheck = [
    "pydantic_graph"
  ];

  sourceRoot = "${finalAttrs.src.name}/pydantic_graph";

  meta = {
    description = "GenAI Agent Framework, the Pydantic way";
    homepage = "https://github.com/pydantic/pydantic-ai";
    changelog = "https://github.com/pydantic/pydantic-ai/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ hexa ];
  };
})
