{
  lib,
  fetchFromGitHub,
  aiofiles,
  aiohttp,
  buildPythonPackage,
  getmac,
  pytest-asyncio,
  pytestCheckHook,
  setuptools,
  websockets,
}:

buildPythonPackage rec {
  pname = "python-pooldose";
  version = "0.9.6";

  src = fetchFromGitHub {
    owner = "lmaertin";
    repo = "python-pooldose";
    tag = version;
    hash = "sha256-eSFe3PRKhVMuwJ7XUHRec8nPilSxGUQ1T2k2loLubUg=";
  };

  nativeCheckInputs = [
    pytest-asyncio
    pytestCheckHook
  ];

  build-system = [ setuptools ];

  dependencies = [
    aiofiles
    aiohttp
    getmac
    websockets
  ];

  pyproject = true;
  pythonImportsCheck = [ "pooldose" ];

  meta = {
    description = "Unoffical async Python client for SEKO PoolDose devices";
    homepage = "https://github.com/lmaertin/python-pooldose";
    changelog = "https://github.com/lmaertin/python-pooldose/blob/${src.tag}/CHANGELOG.md";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ dotlambda ];
  };
}
