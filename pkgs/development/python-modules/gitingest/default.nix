{
  lib,
  fetchFromGitHub,
  boto3,
  buildPythonPackage,
  click,
  fastapi,
  gitMinimal,
  # Tests
  httpx,
  jinja2,
  loguru,
  pathspec,
  prometheus-client,
  pydantic,
  pytest-asyncio,
  pytest-mock,
  pytestCheckHook,
  python-dotenv,
  python-multipart,
  sentry-sdk,
  # Dependencies
  setuptools,
  slowapi,
  starlette,
  tiktoken,
  tomli,
  uvicorn,
}:

buildPythonPackage rec {
  pname = "gitingest";
  version = "0.3.1";

  src = fetchFromGitHub {
    owner = "coderamp-labs";
    repo = "gitingest";
    tag = "v${version}";
    hash = "sha256-drsncGneZyOCC2GJbrDM+bf4QGI2luacxMhrmdk03l4=";
  };

  nativeCheckInputs = [
    jinja2
    gitMinimal
    pytest-asyncio
    pytest-mock
    pytestCheckHook
    python-multipart
  ];

  build-system = [
    setuptools
  ];

  dependencies = [
    boto3
    click
    fastapi
    httpx
    loguru
    pathspec
    prometheus-client
    pydantic
    python-dotenv
    sentry-sdk
    slowapi
    starlette
    tiktoken
    tomli
    uvicorn
  ];

  disabledTests = [
    # Tests require network
    "test_cli_with_default_options"
    "test_cli_with_options"
    "test_cli_with_stdout_output"
    "test_cli_writes_file"
    "test_clone_specific_branch"
    "test_include_ignore_patterns"
    "test_ingest_summary"
    "test_ingest_with_gitignore"
    "test_parse_query_with_branch"
    "test_parse_query_without_host"
    "test_remote_repository_analysis"
    "test_large_repository"
    "test_concurrent_requests"
    "test_large_file_handling"
    "test_repository_with_patterns"
    "test_run_ingest_query"
  ];

  pyproject = true;

  pythonImportsCheck = [
    "gitingest"
  ];

  meta = {
    description = "Replace 'hub' with 'ingest' in any github url to get a prompt-friendly extract of a codebase";
    homepage = "https://github.com/coderamp-labs/gitingest";
    changelog = "https://github.com/coderamp-labs/gitingest/releases/tag/${src.tag}";
    license = lib.licenses.mit;
    maintainers = [ ];
    mainProgram = "gitingest";
  };
}
