{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  # dependencies
  httpx,
  llama-cpp-python,
  llm,
  llm-gguf,
  # build-system
  setuptools,
}:

buildPythonPackage rec {
  pname = "llm-gguf";
  version = "0.2";

  src = fetchFromGitHub {
    owner = "simonw";
    repo = "llm-gguf";
    tag = version;
    hash = "sha256-ihMOiQnTfgZKICVDoQHLOMahrd+GiB+HwWFBMyIcs0A=";
  };

  # Tests require internet access (downloading models)
  doCheck = false;
  build-system = [ setuptools ];

  dependencies = [
    httpx
    llm
    llama-cpp-python
  ];

  pyproject = true;
  pythonImportsCheck = [ "llm_gguf" ];
  passthru.tests = llm.mkPluginTest llm-gguf;

  meta = {
    description = "Run models distributed as GGUF files using LLM";
    homepage = "https://github.com/simonw/llm-gguf";
    changelog = "https://github.com/simonw/llm-gguf/releases/tag/${src.tag}";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ GaetanLepage ];
  };
}
