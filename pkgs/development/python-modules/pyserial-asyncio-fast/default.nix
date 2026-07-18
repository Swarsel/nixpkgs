{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  # dependencies
  pyserial,
  pytest-asyncio,
  # tests
  pytestCheckHook,
  # build-system
  setuptools,
}:

buildPythonPackage rec {
  pname = "pyserial-asyncio-fast";
  version = "0.16";

  src = fetchFromGitHub {
    owner = "bdraco";
    repo = "pyserial-asyncio-fast";
    rev = version;
    hash = "sha256-bEJySiVVy77vSF/M5f3WGxjeay/36vU8oBbmkpDCFrI=";
  };

  patches = [ ./python3.14-compat.patch ];

  nativeCheckInputs = [
    pytestCheckHook
    pytest-asyncio
  ];

  build-system = [ setuptools ];
  dependencies = [ pyserial ];
  pyproject = true;
  pythonImportsCheck = [ "serial_asyncio_fast" ];

  meta = {
    description = "Fast asyncio extension package for pyserial that implements eager writes";
    homepage = "https://github.com/bdraco/pyserial-asyncio-fast";
    changelog = "https://github.com/home-assistant-libs/pyserial-asyncio-fast/releases/tag/${version}";
    license = lib.licenses.bsd3;
    maintainers = with lib.maintainers; [ hexa ];
  };
}
