{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  llm,
  llm-echo,
  pytest-asyncio,
  pytestCheckHook,
  setuptools,
  writableTmpDirAsHomeHook,
}:

buildPythonPackage rec {
  pname = "llm-echo";
  version = "0.4";

  src = fetchFromGitHub {
    owner = "simonw";
    repo = "llm-echo";
    tag = version;
    hash = "sha256-E0C/SZ+0t1iPWulr/xaQQPzRR7Qg7nF/X5/HX8QxkMw=";
  };

  nativeCheckInputs = [
    pytest-asyncio
    pytestCheckHook
    writableTmpDirAsHomeHook
  ];

  build-system = [ setuptools ];
  dependencies = [ llm ];
  pyproject = true;
  pythonImportsCheck = [ "llm_echo" ];
  passthru.tests = llm.mkPluginTest llm-echo;

  meta = {
    description = "Debug plugin for LLM";
    homepage = "https://github.com/simonw/llm-echo";
    changelog = "https://github.com/simonw/llm-echo/releases/tag/${version}/CHANGELOG.md";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ philiptaron ];
  };
}
