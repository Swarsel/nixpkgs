{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  connio,
  fetchpatch,
  pytest-asyncio,
  pytest-cov-stub,
  pytestCheckHook,
  setuptools,
  umodbus,
}:

buildPythonPackage rec {
  pname = "async-modbus";
  version = "0.2.3";

  src = fetchFromGitHub {
    owner = "tiagocoutinho";
    repo = "async_modbus";
    tag = "v${version}";
    hash = "sha256-d4TTs3TtD/9eFdzXBaY+QeAMeRWTvsWeaxONeG0AXJU=";
  };

  patches = [
    (fetchpatch {
      hash = "sha256-mG3XO2nAFYitatkswU7er29BJc/A0IL1rL2Zu4daZ7k=";
      # Fix tests; https://github.com/tiagocoutinho/async_modbus/pull/13
      url = "https://github.com/tiagocoutinho/async_modbus/commit/d81d8ffe94870f0f505e0c8a0694768c98053ecc.patch";
    })
  ];

  postPatch = ''
    substituteInPlace pyproject.toml \
      --replace '"--durations=2", "--verbose"' ""
  '';

  nativeCheckInputs = [
    pytest-asyncio
    pytest-cov-stub
    pytestCheckHook
  ];

  build-system = [ setuptools ];

  dependencies = [
    connio
    umodbus
  ];

  pyproject = true;
  pythonImportsCheck = [ "async_modbus" ];

  meta = {
    description = "Library for Modbus communication";
    homepage = "https://github.com/tiagocoutinho/async_modbus";
    changelog = "https://github.com/tiagocoutinho/async_modbus/releases/tag/${src.tag}";
    license = lib.licenses.gpl3Plus;
    maintainers = with lib.maintainers; [ fab ];
  };
}
