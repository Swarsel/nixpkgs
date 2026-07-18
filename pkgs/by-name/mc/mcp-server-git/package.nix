{
  lib,
  fetchFromGitHub,
  python3Packages,
}:

python3Packages.buildPythonApplication (finalAttrs: {
  pname = "mcp-server-git";
  version = "2026.7.4";

  src = fetchFromGitHub {
    owner = "modelcontextprotocol";
    repo = "servers";
    tag = finalAttrs.version;
    hash = "sha256-rBdJoTC1wOEMbAAeSccFqaHL7lacf2SFfxZ/pp2Lx90=";
  };

  nativeCheckInputs = with python3Packages; [
    pytestCheckHook
  ];

  build-system = with python3Packages; [
    hatchling
  ];

  dependencies = with python3Packages; [
    click
    gitpython
    mcp
    pydantic
  ];

  pyproject = true;
  pythonImportsCheck = [ "mcp_server_git" ];
  sourceRoot = "${finalAttrs.src.name}/src/git/";

  meta = {
    description = "Model Context Protocol server providing tools to read, search, and manipulate Git repositories programmatically via LLMs";
    homepage = "https://github.com/modelcontextprotocol/servers";
    changelog = "https://github.com/modelcontextprotocol/servers/releases/tag/${finalAttrs.version}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ drupol ];
    platforms = lib.platforms.all;
    mainProgram = "mcp-server-git";
  };
})
