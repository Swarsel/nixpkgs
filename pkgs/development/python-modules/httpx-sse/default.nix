{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  httpx,
  pytest-asyncio,
  pytest-cov-stub,
  pytestCheckHook,
  setuptools,
  setuptools-scm,
  sse-starlette,
  starlette,
}:

buildPythonPackage rec {
  pname = "httpx-sse";
  version = "0.4.3";

  src = fetchFromGitHub {
    owner = "florimondmanca";
    repo = "httpx-sse";
    tag = version;
    hash = "sha256-6DPbfJlbLmws9GkQ2zePGp4g0at4M32vrIDtmUPDkX4=";
  };

  nativeCheckInputs = [
    pytest-asyncio
    pytest-cov-stub
    pytestCheckHook
    sse-starlette
    starlette
  ];

  build-system = [
    setuptools
    setuptools-scm
  ];

  dependencies = [ httpx ];
  pyproject = true;
  pythonImportsCheck = [ "httpx_sse" ];

  meta = {
    description = "Consume Server-Sent Event (SSE) messages with HTTPX";
    homepage = "https://github.com/florimondmanca/httpx-sse";
    changelog = "https://github.com/florimondmanca/httpx-sse/blob/${src.rev}/CHANGELOG.md";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ natsukium ];
  };
}
