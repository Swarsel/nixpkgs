{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  # dependencies
  llm,
  llm-perplexity,
  openai,
  pillow,
  # tests
  pytestCheckHook,
  python-dotenv,
  # build-system
  setuptools,
  writableTmpDirAsHomeHook,
}:
buildPythonPackage rec {
  pname = "llm-perplexity";
  version = "2026.2.1";

  src = fetchFromGitHub {
    owner = "hex";
    repo = "llm-perplexity";
    tag = version;
    hash = "sha256-fZrIKIAGXaMwBq2njtqSUcgRHIbr0ajjx6mECoguFm0=";
  };

  nativeCheckInputs = [
    pytestCheckHook
    writableTmpDirAsHomeHook
    python-dotenv
    pillow
  ];

  build-system = [ setuptools ];

  dependencies = [
    llm
    openai
  ];

  pyproject = true;
  pythonImportsCheck = [ "llm_perplexity" ];
  passthru.tests = llm.mkPluginTest llm-perplexity;

  meta = {
    description = "LLM access to pplx-api";
    homepage = "https://github.com/hex/llm-perplexity";
    changelog = "https://github.com/hex/llm-perplexity/releases/tag/${version}";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ jed-richards ];
  };
}
