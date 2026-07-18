{
  lib,
  fetchFromGitHub,
  asynctest,
  buildPythonPackage,
  pyserial-asyncio,
  pytest-asyncio,
  pytestCheckHook,
  setuptools,
  zigpy,
}:

buildPythonPackage (finalAttrs: {
  pname = "zigpy-cc";
  version = "0.5.2";

  # https://github.com/Martiusweb/asynctest/issues/152
  # broken by upstream python bug with asynctest and
  # is used exclusively by home-assistant with python 3.8
  src = fetchFromGitHub {
    owner = "zigpy";
    repo = "zigpy-cc";
    tag = finalAttrs.version;
    hash = "sha256-U3S8tQ3zPlexZDt5GvCd+rOv7CBVeXJJM1NGe7nRl2o=";
  };

  doCheck = false; # asynctest unsupported on 3.11+

  nativeCheckInputs = [
    asynctest
    pytest-asyncio
    pytestCheckHook
  ];

  __structuredAttrs = true;
  build-system = [ setuptools ];

  dependencies = [
    pyserial-asyncio
    zigpy
  ];

  disabledTests = [
    "test_incoming_msg"
    "test_incoming_msg2"
    "test_deser"
    # Fails in sandbox
    "tests/test_application.py "
  ];

  pyproject = true;
  pythonImportsCheck = [ "zigpy_cc" ];

  meta = {
    description = "Library which communicates with Texas Instruments CC2531 radios for zigpy";
    homepage = "https://github.com/zigpy/zigpy-cc";
    license = lib.licenses.gpl3Plus;
    maintainers = with lib.maintainers; [ mvnetbiz ];
    platforms = lib.platforms.linux;
  };
})
