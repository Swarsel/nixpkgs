{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  cogapp,
  llm,
  llm-openai-plugin,
  openai,
  pytest-asyncio,
  pytest-recording,
  pytestCheckHook,
  setuptools,
  syrupy,
  writableTmpDirAsHomeHook,
}:
buildPythonPackage rec {
  pname = "llm-openai-plugin";
  version = "0.7";

  src = fetchFromGitHub {
    owner = "simonw";
    repo = "llm-openai-plugin";
    tag = version;
    hash = "sha256-f/0QvMi2ZF14GtyDIOc9TkHLfbSjjNMe+Wy+60jKO7E=";
  };

  nativeCheckInputs = [
    pytestCheckHook
    pytest-asyncio
    pytest-recording
    syrupy
    cogapp
    writableTmpDirAsHomeHook
  ];

  build-system = [ setuptools ];

  dependencies = [
    llm
    openai
  ];

  pyproject = true;
  pythonImportsCheck = [ "llm_openai" ];
  passthru.tests = llm.mkPluginTest llm-openai-plugin;

  meta = {
    description = "OpenAI plugin for LLM";
    homepage = "https://github.com/simonw/llm-openai-plugin";
    changelog = "https://github.com/simonw/llm-openai-plugin/releases/tag/${src.tag}";
    license = lib.licenses.asl20;

    maintainers = with lib.maintainers; [
      josh
      philiptaron
    ];
  };
}
