{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  coloredlogs,
  jsonschema,
  pytest-asyncio,
  pytest-mock,
  pytestCheckHook,
  serialx,
  setuptools,
  voluptuous,
  zigpy,
}:

buildPythonPackage (finalAttrs: {
  pname = "zigpy-zboss";
  version = "2.0.3";

  src = fetchFromGitHub {
    owner = "kardia-as";
    repo = "zigpy-zboss";
    tag = "v${finalAttrs.version}";
    hash = "sha256-NXla0X1WUg07Px/ZYrmldfXEqYJ/xIryz79/QMiDVn8=";
  };

  nativeCheckInputs = [
    pytest-asyncio
    pytest-mock
    pytestCheckHook
  ];

  build-system = [ setuptools ];

  dependencies = [
    coloredlogs
    jsonschema
    serialx
    voluptuous
    zigpy
  ];

  pyproject = true;
  pythonImportsCheck = [ "zigpy_zboss" ];

  meta = {
    description = "Library for zigpy which communicates with Nordic nRF52 radios";
    homepage = "https://github.com/kardia-as/zigpy-zboss";
    changelog = "https://github.com/kardia-as/zigpy-zboss/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.gpl3Plus;
    maintainers = with lib.maintainers; [ dotlambda ];
  };
})
