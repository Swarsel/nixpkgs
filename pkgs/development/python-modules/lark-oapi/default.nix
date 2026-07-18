{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  httpx,
  pycryptodome,
  pytest-asyncio,
  pytestCheckHook,
  requests,
  requests-toolbelt,
  setuptools,
  websockets,
}:

buildPythonPackage (finalAttrs: {
  pname = "lark-oapi";
  version = "1.6.9";

  src = fetchFromGitHub {
    owner = "larksuite";
    repo = "oapi-sdk-python";
    tag = "v${finalAttrs.version}";
    hash = "sha256-W4eFhB9+XdqA/fX26XwULjvSlflL0ar/FDXWFqXsP8g=";
  };

  nativeCheckInputs = [
    pytest-asyncio
    pytestCheckHook
  ];

  build-system = [ setuptools ];

  dependencies = [
    httpx
    pycryptodome
    requests
    requests-toolbelt
    websockets
  ];

  pyproject = true;
  pythonImportsCheck = [ "lark_oapi" ];
  # websockets 16.0 is compatible despite the <16 metadata constraint
  pythonRelaxDeps = [ "websockets" ];

  meta = {
    description = "Larksuite development interface SDK";
    homepage = "https://github.com/larksuite/oapi-sdk-python";
    license = lib.licenses.mit;
    maintainers = [ lib.maintainers.knightfemale ];
  };
})
