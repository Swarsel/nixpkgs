{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  # tests
  coverage,
  # dependencies
  fastapi,
  # build-system
  hatchling,
  httpx,
  mcp,
  pydantic,
  pydantic-settings,
  pytest-asyncio_0,
  pytest-cov-stub,
  pytestCheckHook,
  requests,
  rich,
  tomli,
  typer,
  uvicorn,
}:

buildPythonPackage rec {
  pname = "fastapi-mcp";
  version = "0.4.0";

  src = fetchFromGitHub {
    owner = "tadata-org";
    repo = "fastapi_mcp";
    tag = "v${version}";
    hash = "sha256-TCmM5n6BF3CWEuGVSZnUL2rTYitKtn4vSCkiQvKFLKw=";
  };

  nativeCheckInputs = [
    coverage
    pytest-asyncio_0
    pytest-cov-stub
    pytestCheckHook
  ];

  __darwinAllowLocalNetworking = true;

  build-system = [
    hatchling
    tomli
  ];

  dependencies = [
    fastapi
    httpx
    mcp
    pydantic
    pydantic-settings
    requests
    rich
    tomli
    typer
    uvicorn
  ];

  disabledTestPaths = [
    # Flaky, would try to allocate a port on Darwin
    "tests/test_sse_real_transport.py"
  ];

  pyproject = true;
  pythonImportsCheck = [ "fastapi_mcp" ];

  meta = {
    description = "Expose your FastAPI endpoints as Model Context Protocol (MCP) tools, with Auth";
    homepage = "https://github.com/tadata-org/fastapi_mcp";
    changelog = "https://github.com/tadata-org/fastapi_mcp/blob/${src.tag}/CHANGELOG.md";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ GaetanLepage ];
  };
}
