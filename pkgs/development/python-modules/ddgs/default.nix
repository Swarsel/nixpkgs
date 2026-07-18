{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  click,
  fastapi,
  lxml,
  mcp,
  primp,
  setuptools,
  trio,
  uvicorn,
  versionCheckHook,
}:

buildPythonPackage (finalAttrs: {
  pname = "ddgs";
  version = "9.14.2";

  src = fetchFromGitHub {
    owner = "deedy5";
    repo = "ddgs";
    tag = "v${finalAttrs.version}";
    hash = "sha256-4kTGiEVsmjlPH8pAbAoeTrC6a/ZshsPSErmPkLRwR9A=";
  };

  nativeCheckInputs = [ versionCheckHook ];
  build-system = [ setuptools ];

  dependencies = [
    click
    lxml
    primp
  ];

  optional-dependencies = {
    api = [
      fastapi
      uvicorn
    ];

    dht = [
      fastapi
      uvicorn
      trio
    ];

    mcp = [
      mcp
    ];
  };

  pyproject = true;
  pythonImportsCheck = [ "ddgs" ];
  versionCheckProgramArg = "version";

  meta = {
    description = "A metasearch library that aggregates results from diverse web search services";
    homepage = "https://github.com/deedy5/ddgs";
    changelog = "https://github.com/deedy5/ddgs/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ drawbu ];
    mainProgram = "ddgs";
  };
})
