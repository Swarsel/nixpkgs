{
  lib,
  fetchFromGitHub,
  aiohttp,
  buildPythonPackage,
  pytest-asyncio,
  pytestCheckHook,
  setuptools,
}:

buildPythonPackage (finalAttrs: {
  pname = "airpatrol";
  version = "0.1.0";

  src = fetchFromGitHub {
    owner = "antondalgren";
    repo = "airpatrol";
    tag = "v${finalAttrs.version}";
    hash = "sha256-KPch1GsJ5my43d9SVpwGA2EmrkmeBGJWAkY51rDofTk=";
  };

  nativeCheckInputs = [
    pytestCheckHook
    pytest-asyncio
  ];

  build-system = [ setuptools ];
  dependencies = [ aiohttp ];
  pyproject = true;
  pythonImportsCheck = [ "airpatrol" ];

  meta = {
    description = "Python package for interacting with AirPatrol devices";
    homepage = "https://github.com/antondalgren/airpatrol";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ jamiemagee ];
  };
})
