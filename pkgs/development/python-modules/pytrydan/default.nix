{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  httpx,
  orjson,
  poetry-core,
  pytest-asyncio,
  pytest-cov-stub,
  pytestCheckHook,
  respx,
  rich,
  syrupy,
  tenacity,
  typer,
}:

buildPythonPackage (finalAttrs: {
  pname = "pytrydan";
  version = "1.0.2";

  src = fetchFromGitHub {
    owner = "dgomes";
    repo = "pytrydan";
    tag = "v${finalAttrs.version}";
    hash = "sha256-vxIY+BCo3o4FBI1otiMx3swWTxtmEgYfVCWQAq2OuUM=";
  };

  nativeCheckInputs = [
    pytest-asyncio
    pytest-cov-stub
    pytestCheckHook
    respx
    syrupy
  ];

  build-system = [ poetry-core ];

  dependencies = [
    httpx
    orjson
    rich
    tenacity
    typer
  ];

  pyproject = true;
  pythonImportsCheck = [ "pytrydan" ];
  pythonRelaxDeps = [ "tenacity" ];

  meta = {
    description = "Library to interface with V2C EVSE Trydan";
    homepage = "https://github.com/dgomes/pytrydan";
    changelog = "https://github.com/dgomes/pytrydan/blob/${finalAttrs.src.tag}/CHANGELOG.md";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ fab ];
    mainProgram = "pytrydan";
  };
})
