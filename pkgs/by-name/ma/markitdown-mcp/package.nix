{
  lib,
  fetchFromGitHub,
  gitUpdater,
  python3Packages,
}:

python3Packages.buildPythonApplication (finalAttrs: {
  pname = "markitdown-mcp";
  version = "0.1.5";

  src = fetchFromGitHub {
    owner = "microsoft";
    repo = "markitdown";
    tag = "v${finalAttrs.version}";
    hash = "sha256-sqWfft/yaI/0FavhIbAHqltgVfTNk0GJk/phyvdn7Ck=";
  };

  build-system = [
    python3Packages.hatchling
  ];

  dependencies = with python3Packages; [
    markitdown
    mcp
  ];

  pyproject = true;

  pythonImportsCheck = [
    "markitdown_mcp"
  ];

  pythonRelaxDeps = [
    "mcp"
  ];

  sourceRoot = "${finalAttrs.src.name}/packages/markitdown-mcp";
  passthru.updateScript = gitUpdater { };

  meta = {
    description = "MCP server for the markitdown library";
    homepage = "https://github.com/microsoft/markitdown/tree/main/packages/markitdown-mcp";
    changelog = "https://github.com/microsoft/markitdown/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.mit;
    maintainers = python3Packages.markitdown.meta.maintainers;
    platforms = lib.platforms.all;
    mainProgram = "markitdown-mcp";
  };
})
