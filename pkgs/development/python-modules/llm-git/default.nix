{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  click,
  deepmerge,
  llm,
  llm-git,
  pygments,
  pytest-asyncio,
  pytest-cov-stub,
  pytest-httpx,
  pytestCheckHook,
  pyyaml,
  rich,
  setuptools,
  writableTmpDirAsHomeHook,
}:

buildPythonPackage rec {
  pname = "llm-git";
  version = "0.2.2";

  src = fetchFromGitHub {
    owner = "OttoAllmendinger";
    repo = "llm-git";
    tag = "v${version}";
    hash = "sha256-LcIsJPQgZ4gj2t7sSa0Wu35WHWYyquZZTS/UxojH+XU=";
  };

  nativeCheckInputs = [
    pytestCheckHook
    pytest-cov-stub
    writableTmpDirAsHomeHook
  ];

  build-system = [
    setuptools
  ];

  dependencies = [
    click
    deepmerge
    llm
    pyyaml
    rich
    pygments
  ];

  pyproject = true;
  pythonImportsCheck = [ "llm_git" ];
  passthru.tests = llm.mkPluginTest llm-git;

  meta = {
    description = "AI-powered Git commands for the LLM CLI tool";
    homepage = "https://github.com/OttoAllmendinger/llm-git";
    changelog = "https://github.com/OttoAllmendinger/llm-git/releases/tag/${version}/CHANGELOG.md";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ philiptaron ];
  };
}
