{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  llm,
  llm-github-copilot,
  pytest-asyncio,
  pytest-vcr,
  pytestCheckHook,
  setuptools,
  writableTmpDirAsHomeHook,
}:

buildPythonPackage rec {
  pname = "llm-github-copilot";
  version = "0.3.1";

  src = fetchFromGitHub {
    owner = "jmdaly";
    repo = "llm-github-copilot";
    tag = version;
    hash = "sha256-BUVpt1Vv0+kxbTYHDdiYy3+ySJKWJ9b+dYexV7YS+NI=";
  };

  nativeCheckInputs = [
    pytestCheckHook
    writableTmpDirAsHomeHook
    pytest-vcr
    pytest-asyncio
  ];

  build-system = [ setuptools ];
  dependencies = [ llm ];
  pyproject = true;
  pythonImportsCheck = [ "llm_github_copilot" ];
  passthru.tests = llm.mkPluginTest llm-github-copilot;

  meta = {
    description = "LLM plugin providing access to GitHub Copilot";
    homepage = "https://github.com/jmdaly/llm-github-copilot";
    changelog = "https://github.com/jmdaly/llm-github-copilot/releases/tag/${src.tag}";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ afh ];
  };
}
