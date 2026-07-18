{
  lib,
  fetchFromGitHub,
  python3Packages,
}:

python3Packages.buildPythonApplication (finalAttrs: {
  pname = "mcp-server-time";
  version = "2026.7.4";

  src = fetchFromGitHub {
    owner = "modelcontextprotocol";
    repo = "servers";
    tag = finalAttrs.version;
    hash = "sha256-rBdJoTC1wOEMbAAeSccFqaHL7lacf2SFfxZ/pp2Lx90=";
  };

  nativeCheckInputs = with python3Packages; [
    freezegun
    pytestCheckHook
  ];

  build-system = with python3Packages; [
    hatchling
  ];

  dependencies = with python3Packages; [
    mcp
    pydantic
    tzdata
    tzlocal
  ];

  pyproject = true;
  pythonImportsCheck = [ "mcp_server_time" ];
  sourceRoot = "${finalAttrs.src.name}/src/time/";

  meta = {
    description = "Model Context Protocol server providing tools for time queries and timezone conversions for LLMs";
    homepage = "https://github.com/modelcontextprotocol/servers";
    changelog = "https://github.com/modelcontextprotocol/servers/releases/tag/${finalAttrs.version}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ drupol ];
    platforms = lib.platforms.all;
    mainProgram = "mcp-server-time";
  };
})
