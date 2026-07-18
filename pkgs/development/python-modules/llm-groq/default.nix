{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  groq,
  llm,
  llm-groq,
  setuptools,
}:

buildPythonPackage rec {
  pname = "llm-groq";
  version = "0.9";

  src = fetchFromGitHub {
    owner = "angerman";
    repo = "llm-groq";
    tag = "v${version}";
    hash = "sha256-9obDB5xz/YFKdnqM/70SC4Ud1t62AsGzAkbGsZTL5Nc=";
  };

  build-system = [
    setuptools
  ];

  dependencies = [
    groq
    llm
  ];

  pyproject = true;
  pythonImportsCheck = [ "llm_groq" ];
  passthru.tests = llm.mkPluginTest llm-groq;

  meta = {
    description = "LLM plugin providing access to Groqcloud models.";
    homepage = "https://github.com/angerman/llm-groq";
    changelog = "https://github.com/angerman/llm-groq/releases/tag/${src.tag}/CHANGELOG.md";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ philiptaron ];
  };
}
