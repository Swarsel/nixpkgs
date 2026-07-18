{
  lib,
  fetchFromGitHub,
  aenum,
  aiohttp,
  aioresponses,
  buildPythonPackage,
  hatchling,
  pydantic,
  pytest-asyncio,
  pytest-httpx,
  pytestCheckHook,
  rich,
}:

buildPythonPackage (finalAttrs: {
  pname = "intellifire4py";
  version = "4.5.0";

  src = fetchFromGitHub {
    owner = "jeeftor";
    repo = "intellifire4py";
    tag = "v${finalAttrs.version}";
    hash = "sha256-MBuKYBKV0376j048tfbqMD9p2Gh1wlC188SGOMSMSm8=";
  };

  nativeCheckInputs = [
    aioresponses
    pytest-asyncio
    pytest-httpx
    pytestCheckHook
  ];

  build-system = [ hatchling ];

  dependencies = [
    aiohttp
    aenum
    pydantic
    rich
  ];

  pyproject = true;
  pythonImportsCheck = [ "intellifire4py" ];

  meta = {
    description = "Module to read Intellifire fireplace status data";
    homepage = "https://github.com/jeeftor/intellifire4py";
    changelog = "https://github.com/jeeftor/intellifire4py/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ fab ];
    mainProgram = "intellifire4py";

  };
})
