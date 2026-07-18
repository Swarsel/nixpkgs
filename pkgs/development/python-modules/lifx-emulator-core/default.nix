{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  hatchling,
  pydantic,
  pytest-asyncio,
  pytestCheckHook,
  pyyaml,
  writableTmpDirAsHomeHook,
}:

buildPythonPackage (finalAttrs: {
  pname = "lifx-emulator-core";
  version = "3.6.3";

  src = fetchFromGitHub {
    owner = "Djelibeybi";
    repo = "lifx-emulator";
    tag = "core-v${finalAttrs.version}";
    hash = "sha256-bZ+u/OKFDYV0kQLeVQPDyLKC9KCTJydbl0xnuOsrh+0=";
  };

  nativeCheckInputs = [
    pytest-asyncio
    pytestCheckHook
    writableTmpDirAsHomeHook
  ];

  __darwinAllowLocalNetworking = true;
  build-system = [ hatchling ];

  dependencies = [
    pydantic
    pyyaml
  ];

  pyproject = true;
  pythonImportsCheck = [ "lifx_emulator" ];
  sourceRoot = "${finalAttrs.src.name}/packages/lifx-emulator-core";

  meta = {
    description = "Core Python library for emulating LIFX devices using the LAN protocol";
    homepage = "https://github.com/Djelibeybi/lifx-emulator/tree/main/packages/lifx-emulator-core";
    license = lib.licenses.upl;
    maintainers = with lib.maintainers; [ SuperSandro2000 ];
  };
})
