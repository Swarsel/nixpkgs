{
  lib,
  fetchFromGitHub,
  anthropic,
  buildPythonPackage,
  json-schema-to-pydantic,
  llm,
  llm-anthropic,
  pytest-asyncio,
  pytest-recording,
  pytestCheckHook,
  setuptools,
  writableTmpDirAsHomeHook,
}:

buildPythonPackage (finalAttrs: {
  pname = "llm-anthropic";
  version = "0.25.1";

  src = fetchFromGitHub {
    owner = "simonw";
    repo = "llm-anthropic";
    tag = finalAttrs.version;
    hash = "sha256-b9XnPxKDGsiy20Me70sYrkMVO36OF3EwWOHLyEd5z4E=";
  };

  nativeCheckInputs = [
    pytestCheckHook
    pytest-asyncio
    pytest-recording
    writableTmpDirAsHomeHook
  ];

  build-system = [
    setuptools
  ];

  dependencies = [
    anthropic
    json-schema-to-pydantic
    llm
  ];

  disabledTests = [
    # Need to be run as a passthru test
    "test_async_prompt"
    "test_image_prompt"
    "test_prompt"
    "test_schema_prompt"
    "test_thinking_prompt"
  ];

  pyproject = true;
  pythonImportsCheck = [ "llm_anthropic" ];
  passthru.tests = llm.mkPluginTest llm-anthropic;

  meta = {
    description = "LLM access to models by Anthropic, including the Claude series";
    homepage = "https://github.com/simonw/llm-anthropic";
    changelog = "https://github.com/simonw/llm-anthropic/releases/tag/${finalAttrs.src.tag}/CHANGELOG.md";
    license = lib.licenses.asl20;

    maintainers = with lib.maintainers; [
      aos
      sarahec
    ];
  };
})
