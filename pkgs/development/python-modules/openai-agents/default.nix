{
  lib,
  buildPythonPackage,
  fetchPypi,
  griffelib,
  hatchling,
  mcp,
  openai,
  pydantic,
  requests,
  types-requests,
  typing-extensions,
}:

buildPythonPackage (finalAttrs: {
  pname = "openai-agents";
  version = "0.17.6";

  src = fetchPypi {
    inherit (finalAttrs) version;
    hash = "sha256-/tlPjPDrTFfGOomtSxB5MtdfKgttnolciPo8IX5jyCI=";
    pname = "openai_agents";
  };

  build-system = [
    hatchling
  ];

  dependencies = [
    griffelib
    mcp
    openai
    pydantic
    requests
    types-requests
    typing-extensions
  ];

  pyproject = true;

  pythonImportsCheck = [
    "agents"
  ];

  meta = {
    description = "Lightweight, powerful framework for multi-agent workflows";
    homepage = "https://github.com/openai/openai-agents-python";
    changelog = "https://github.com/openai/openai-agents-python/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.mit;
    maintainers = [ lib.maintainers.bryanhonof ];
  };
})
