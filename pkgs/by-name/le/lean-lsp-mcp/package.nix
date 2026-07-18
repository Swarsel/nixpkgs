{
  lib,
  fetchFromGitHub,
  python3Packages,
}:

python3Packages.buildPythonApplication (finalAttrs: {
  pname = "lean-lsp-mcp";
  version = "0.26.2";

  src = fetchFromGitHub {
    owner = "oOo0oOo";
    repo = "lean-lsp-mcp";
    tag = "v${finalAttrs.version}";
    hash = "sha256-NWX+r6hz04WnSkERqVj57ruw47RhqOeEofYUaxuU/uM=";
  };

  # Tests require a real Lean toolchain
  doCheck = false;
  __structuredAttrs = true;
  build-system = with python3Packages; [ setuptools ];

  dependencies = with python3Packages; [
    leanclient
    mcp
    orjson
    certifi
  ];

  pyproject = true;
  pythonImportsCheck = [ "lean_lsp_mcp" ];

  pythonRelaxDeps = [
    "mcp"
    "leanclient"
  ];

  meta = {
    description = "MCP server for the Lean theorem prover via the Lean LSP";
    homepage = "https://github.com/oOo0oOo/lean-lsp-mcp";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ remix7531 ];
    mainProgram = "lean-lsp-mcp";
  };
})
