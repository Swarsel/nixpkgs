{
  lib,
  baize,
  buildPythonPackage,
  fetchPypi,
  httpx,
  pdm-backend,
  pytest-asyncio,
  pytestCheckHook,
  starlette,
}:

buildPythonPackage rec {
  pname = "a2wsgi";
  version = "1.10.10";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-pbz/tSCBujnfDV6aiE/G+BnZLjpCOJNDunfL+An+H0U=";
  };

  nativeCheckInputs = [
    baize
    httpx
    pytest-asyncio
    pytestCheckHook
    starlette
  ];

  build-system = [ pdm-backend ];

  dependencies = [
    starlette
    baize
  ];

  pyproject = true;

  meta = {
    description = "Convert WSGI app to ASGI app or ASGI app to WSGI app";
    homepage = "https://github.com/abersheeran/a2wsgi";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ SuperSandro2000 ];
  };
}
