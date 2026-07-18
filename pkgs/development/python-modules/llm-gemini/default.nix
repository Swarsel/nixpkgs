{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  httpx,
  ijson,
  llm,
  llm-gemini,
  nest-asyncio,
  pytest-asyncio,
  pytest-recording,
  pytestCheckHook,
  setuptools,
  writableTmpDirAsHomeHook,
}:
buildPythonPackage rec {
  pname = "llm-gemini";
  version = "0.32";

  src = fetchFromGitHub {
    owner = "simonw";
    repo = "llm-gemini";
    tag = version;
    hash = "sha256-h8aZvkZNDj7Vcc1HZ7mHVYk99Upoeazp0ET6yeRiySo=";
  };

  nativeCheckInputs = [
    pytestCheckHook
    pytest-recording
    pytest-asyncio
    nest-asyncio
    writableTmpDirAsHomeHook
  ];

  build-system = [ setuptools ];

  dependencies = [
    httpx
    ijson
    llm
  ];

  pyproject = true;
  pythonImportsCheck = [ "llm_gemini" ];
  passthru.tests = llm.mkPluginTest llm-gemini;

  meta = {
    description = "LLM plugin to access Google's Gemini family of models";
    homepage = "https://github.com/simonw/llm-gemini";
    changelog = "https://github.com/simonw/llm-gemini/releases/tag/${src.tag}";
    license = lib.licenses.asl20;

    maintainers = with lib.maintainers; [
      josh
      philiptaron
    ];
  };
}
