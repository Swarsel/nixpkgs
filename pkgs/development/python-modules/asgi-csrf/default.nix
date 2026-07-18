{
  lib,
  fetchFromGitHub,
  # tests
  asgi-lifespan,
  buildPythonPackage,
  httpx,
  # dependencies
  itsdangerous,
  pytest-asyncio,
  pytestCheckHook,
  python-multipart,
  # build-system
  setuptools,
  starlette,
}:

buildPythonPackage rec {
  pname = "asgi-csrf";
  version = "0.11";

  # PyPI tarball doesn't include tests directory
  src = fetchFromGitHub {
    owner = "simonw";
    repo = "asgi-csrf";
    tag = version;
    hash = "sha256-STitMWabAPz61AU+5gFJSHBBqf67Q8UtS6ks8Q/ZybY=";
  };

  nativeCheckInputs = [
    asgi-lifespan
    httpx
    pytest-asyncio
    pytestCheckHook
    starlette
  ];

  build-system = [ setuptools ];

  dependencies = [
    itsdangerous
    python-multipart
  ];

  pyproject = true;
  pythonImportsCheck = [ "asgi_csrf" ];

  meta = {
    description = "ASGI middleware for protecting against CSRF attacks";
    homepage = "https://github.com/simonw/asgi-csrf";
    license = lib.licenses.asl20;
    maintainers = [ lib.maintainers.ris ];
    # https://github.com/simonw/asgi-csrf/issues/38
    broken = lib.versionAtLeast python-multipart.version "0.0.26";
  };
}
