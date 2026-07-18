{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  claude-agent-sdk,
  hatchling,
  nix-update-script,
  openinference-instrumentation,
  openinference-semantic-conventions,
  opentelemetry-api,
  opentelemetry-instrumentation,
  opentelemetry-semantic-conventions,
  pytest-asyncio,
  pytest-timeout,
  pytestCheckHook,
  pyyaml,
  sniffio,
  typing-extensions,
  wrapt,
}:

buildPythonPackage (finalAttrs: {
  pname = "openinference-instrumentation-claude-agent-sdk";
  version = "0.1.7";

  src = fetchFromGitHub {
    owner = "Arize-ai";
    repo = "openinference";
    tag = "python-openinference-instrumentation-claude-agent-sdk-v${finalAttrs.version}";
    hash = "sha256-BqDIHI2moNW+m5/CC7NLL0fLzAF9aGv5ncoVe6B2cRQ=";
  };

  nativeCheckInputs = [
    pytest-asyncio
    pytest-timeout
    pytestCheckHook
    pyyaml
    sniffio
  ]
  ++ lib.flatten (builtins.attrValues finalAttrs.passthru.optional-dependencies);

  __structuredAttrs = true;
  build-system = [ hatchling ];

  dependencies = [
    opentelemetry-api
    opentelemetry-instrumentation
    opentelemetry-semantic-conventions
    openinference-semantic-conventions
    openinference-instrumentation
    typing-extensions
    wrapt
  ];

  optional-dependencies = {
    instruments = [ claude-agent-sdk ];
  };

  pyproject = true;
  pythonImportsCheck = [ "openinference.instrumentation.claude_agent_sdk" ];
  sourceRoot = "${finalAttrs.src.name}/python/instrumentation/${finalAttrs.pname}";
  passthru.updateScript = nix-update-script { };

  meta = {
    description = "OpenInference Claude Agent SDK Instrumentation";
    homepage = "https://github.com/Arize-ai/openinference";
    changelog = "https://github.com/Arize-ai/openinference/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ fab ];
  };
})
