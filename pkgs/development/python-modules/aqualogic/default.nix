{
  lib,
  fetchFromGitHub,
  aiohttp,
  buildPythonPackage,
  pyserial,
  pytestCheckHook,
  setuptools,
  websockets,
}:

buildPythonPackage (finalAttrs: {
  pname = "aqualogic";
  version = "3.4";

  src = fetchFromGitHub {
    owner = "swilson";
    repo = "aqualogic";
    tag = finalAttrs.version;
    hash = "sha256-hBg02Wypd+MyqM2SUD53djhm5OMP2QAmsp8Stf+UT2c=";
  };

  # With 3.4 the event loop is not terminated after the first test
  # https://github.com/swilson/aqualogic/issues/9
  doCheck = false;
  nativeCheckInputs = [ pytestCheckHook ];
  build-system = [ setuptools ];

  dependencies = [
    aiohttp
    pyserial
    websockets
  ];

  pyproject = true;
  pythonImportsCheck = [ "aqualogic" ];

  meta = {
    description = "Python library to interface with Hayward/Goldline AquaLogic/ProLogic pool controllers";
    homepage = "https://github.com/swilson/aqualogic";
    changelog = "https://github.com/swilson/aqualogic/releases/tag/${finalAttrs.version}";
    license = with lib.licenses; [ mit ];
    maintainers = with lib.maintainers; [ fab ];
  };
})
