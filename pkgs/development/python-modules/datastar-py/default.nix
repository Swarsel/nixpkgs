{
  lib,
  fetchFromGitHub,
  anyio,
  buildPythonPackage,
  django,
  fastapi,
  hatchling,
  httpx,
  litestar,
  pytestCheckHook,
  starlette,
  uvicorn,
}:

buildPythonPackage (finalAttrs: {
  pname = "datastar-py";
  version = "1.0.2";

  src = fetchFromGitHub {
    owner = "starfederation";
    repo = "datastar-python";
    tag = "v${finalAttrs.version}";
    hash = "sha256-epshwHwpRnrgOQ6/jiy6Iyv4y1fa5ZipgiFShKEOxtA=";
  };

  nativeCheckInputs = [
    anyio
    django
    fastapi
    httpx
    litestar
    pytestCheckHook
    starlette
    uvicorn
  ];

  build-system = [ hatchling ];
  pyproject = true;
  pythonImportsCheck = [ "datastar_py" ];

  meta = {
    description = "Helper functions and classes for the Datastar library";
    homepage = "https://github.com/starfederation/datastar-python";
    changelog = "https://github.com/starfederation/datastar-python/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.mit;
    maintainers = [ lib.maintainers.dotlambda ];
  };
})
