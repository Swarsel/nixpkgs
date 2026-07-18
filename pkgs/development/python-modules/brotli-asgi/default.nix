{
  lib,
  fetchFromGitHub,
  brotli,
  brotlipy,
  buildPythonPackage,
  # check inputs
  httpx,
  mypy,
  requests,
  setuptools,
  # build inputs
  starlette,
}:
buildPythonPackage (finalAttrs: {
  pname = "brotli-asgi";
  version = "1.6.0";

  src = fetchFromGitHub {
    owner = "fullonic";
    repo = "brotli-asgi";
    tag = "v${finalAttrs.version}";
    hash = "sha256-cF7A3mnkQmvtc9DgHiwqYEQQ6QagjoBGTmcBzUm6vvs=";
  };

  nativeCheckInputs = [
    httpx
    requests
    mypy
    brotlipy
  ];

  __structuredAttrs = true;
  build-system = [ setuptools ];

  dependencies = [
    starlette
    brotli
  ];

  pyproject = true;
  pythonImportsCheck = [ "brotli_asgi" ];

  meta = {
    description = "Compression AGSI middleware using brotli";
    homepage = "https://github.com/fullonic/brotli-asgi";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ happysalada ];
  };
})
