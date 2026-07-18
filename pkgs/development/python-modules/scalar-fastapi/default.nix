{
  lib,
  fetchFromGitHub,
  # python dependencies
  annotated-types,
  anyio,
  buildPythonPackage,
  fastapi,
  httpx,
  idna,
  pydantic,
  # tests
  pytestCheckHook,
  # build-system
  setuptools,
  sniffio,
  starlette,
  typing-extensions,
}:

buildPythonPackage rec {
  pname = "scalar-fastapi";
  version = "1.8.2";

  src = fetchFromGitHub {
    owner = "scalar";
    repo = "scalar";
    # The commit changed integrations/fastapi/package.json which defines version number
    rev = "0f4bd9da2706be09a8afba017465f55a62dc0975";
    hash = "sha256-FvbRsLEfdG2fqg14xXG0K1nn8+qX/Co9Sy2EOM0DTlg=";
    pname = "scalar_fastapi";
  };

  nativeCheckInputs = [
    pytestCheckHook
    httpx
  ];

  build-system = [
    setuptools
  ];

  dependencies = [
    annotated-types
    anyio
    fastapi
    idna
    pydantic
    sniffio
    starlette
    typing-extensions
  ];

  pyproject = true;

  pythonImportsCheck = [
    "scalar_fastapi"
  ];

  sourceRoot = "${src.name}/integrations/fastapi";

  meta = {
    description = "Plugin for FastAPI to render a reference for your OpenAPI document";
    homepage = "https://github.com/scalar/scalar/";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ codgician ];
  };
}
