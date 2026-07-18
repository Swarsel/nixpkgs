{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  numpy,
  ollama,
  openai,
  python-redis-lock,
  setuptools,
  umap-learn,
}:

buildPythonPackage (finalAttrs: {
  pname = "pretalx-llm";
  version = "0.5.1";

  src = fetchFromGitHub {
    owner = "why2025-datenzone";
    repo = "pretalx-llm";
    rev = "v${finalAttrs.version}";
    hash = "sha256-KnL4X24RESAgO0Oh1k9c+K4zaho6CEFHMQvDeRdLBzs=";
  };

  doCheck = false; # no tests

  build-system = [
    setuptools
  ];

  dependencies = [
    numpy
    ollama
    openai
    python-redis-lock
    umap-learn
  ];

  pyproject = true;

  pythonImportsCheck = [
    "pretalx_llm"
  ];

  meta = {
    description = "LLM support for Pretalx";
    homepage = "https://github.com/why2025-datenzone/pretalx-llm";
    changelog = "https://github.com/why2025-datenzone/pretalx-llm/blob/${finalAttrs.src.rev}/CHANGELOG.md";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ hexa ];
  };
})
