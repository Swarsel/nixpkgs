{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  llm,
  llm-echo,
  llm-tools-sqlite,
  pytestCheckHook,
  setuptools,
  writableTmpDirAsHomeHook,
}:

buildPythonPackage rec {
  pname = "llm-tools-sqlite";
  version = "0.1";

  src = fetchFromGitHub {
    owner = "simonw";
    repo = "llm-tools-sqlite";
    tag = version;
    hash = "sha256-VAmK4cXzZWTWCU92TwMdhNJPvYPZ88t5BZe8vo60SZY=";
  };

  nativeCheckInputs = [
    llm-echo
    pytestCheckHook
    writableTmpDirAsHomeHook
  ];

  build-system = [ setuptools ];
  dependencies = [ llm ];
  pyproject = true;
  pythonImportsCheck = [ "llm_tools_sqlite" ];
  passthru.tests = llm.mkPluginTest llm-tools-sqlite;

  meta = {
    description = "LLM tools for running queries against SQLite";
    homepage = "https://github.com/simonw/llm-tools-sqlite";
    changelog = "https://github.com/simonw/llm-tools-sqlite/releases/tag/${version}/CHANGELOG.md";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ philiptaron ];
  };
}
