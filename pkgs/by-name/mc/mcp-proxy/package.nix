{
  lib,
  fetchFromGitHub,
  python3Packages,
}:
python3Packages.buildPythonApplication (finalAttrs: {
  pname = "mcp-proxy";
  version = "0.10.0";

  src = fetchFromGitHub {
    owner = "sparfenyuk";
    repo = "mcp-proxy";
    tag = "v${finalAttrs.version}";
    hash = "sha256-Hig+ZDFdToiYGOjb/rpqxnu8MaLmQLgSh5WYcgJGA1I=";
  };

  nativeCheckInputs = with python3Packages; [
    pytestCheckHook
    pytest-asyncio
  ];

  __darwinAllowLocalNetworking = true;
  build-system = [ python3Packages.setuptools ];

  dependencies = with python3Packages; [
    uvicorn
    mcp
  ];

  disabledTests = [
    # AssertionError: expected call not found.
    # Expected: mock(PromptReference(type='ref/prompt', name='name'), CompletionArgument(name='name', value='value'))
    #   Actual: mock(PromptReference(type='ref/prompt', name='name'), CompletionArgument(name='name', value='value'), None)
    "test_call_tool[server-AsyncMock]"
    "test_call_tool[proxy-AsyncMock]"
    "test_complete[server-AsyncMock]"
    "test_complete[proxy-AsyncMock]"
  ];

  pyproject = true;

  meta = {
    description = "MCP server which proxies other MCP servers from stdio to SSE or from SSE to stdio";
    homepage = "https://github.com/sparfenyuk/mcp-proxy";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ keyruu ];
    mainProgram = "mcp-proxy";
  };
})
