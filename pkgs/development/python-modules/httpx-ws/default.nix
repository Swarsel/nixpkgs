{
  lib,
  fetchFromGitHub,
  anyio,
  buildPythonPackage,
  hatchling,
  httpcore,
  httpx,
  pytest-cov-stub,
  pytestCheckHook,
  starlette,
  trio,
  uvicorn,
  wsproto,
}:

buildPythonPackage rec {
  pname = "httpx-ws";
  version = "0.8.2";

  src = fetchFromGitHub {
    owner = "frankie567";
    repo = "httpx-ws";
    tag = "v${version}";
    hash = "sha256-3gSXUpHs1tF8FJ7Jz174VBoRCrepYcpYU1FZaNMpZqg=";
  };

  # we don't need to use the hatch-regex-commit plugin
  postPatch = ''
    substituteInPlace pyproject.toml \
      --replace-fail 'source = "regex_commit"' "" \
      --replace-fail 'commit_extra_args = ["-e"]' "" \
      --replace-fail '"hatch-regex-commit"' ""
  '';

  nativeCheckInputs = [
    pytestCheckHook
    pytest-cov-stub
    starlette
    trio
    uvicorn
  ];

  build-system = [ hatchling ];

  dependencies = [
    anyio
    httpcore
    httpx
    wsproto
  ];

  disabledTestPaths = [
    # hang
    "tests/test_api.py"
  ];

  pyproject = true;
  pythonImportsCheck = [ "httpx_ws" ];

  meta = {
    description = "WebSocket support for HTTPX";
    homepage = "https://github.com/frankie567/httpx-ws";
    changelog = "https://github.com/frankie567/httpx-ws/releases/tag/${src.tag}";
    license = lib.licenses.mit;
    maintainers = [ ];
  };
}
