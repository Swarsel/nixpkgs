{
  lib,
  fetchFromGitHub,
  python3Packages,
}:

python3Packages.buildPythonApplication (finalAttrs: {
  pname = "mcp-server-fetch";
  version = "2026.7.4";

  src = fetchFromGitHub {
    owner = "modelcontextprotocol";
    repo = "servers";
    rev = "f4244583a6af9425633e433a3eec000d23f4e011";
    hash = "sha256-bHknioQu8i5RcFlBBdXUQjsV4WN1IScnwohGRxXgGDk=";
  };

  # Tests require network access
  doCheck = false;

  build-system = with python3Packages; [
    hatchling
  ];

  dependencies = with python3Packages; [
    httpx
    markdownify
    mcp
    protego
    pydantic
    readabilipy
    requests
  ];

  pyproject = true;
  pythonImportsCheck = [ "mcp_server_fetch" ];
  sourceRoot = "${finalAttrs.src.name}/src/fetch/";

  meta = {
    description = "Model Context Protocol server providing tools to fetch and convert web content for usage by LLMs";
    homepage = "https://github.com/modelcontextprotocol/servers";
    changelog = "https://github.com/modelcontextprotocol/servers/releases/tag/${finalAttrs.version}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ drupol ];
    platforms = lib.platforms.all;
    mainProgram = "mcp-server-fetch";
  };
})
