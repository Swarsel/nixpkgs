{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  hatchling,
  pymodbus,
  pytest-asyncio,
  pytest-mock,
  pytestCheckHook,
}:

buildPythonPackage (finalAttrs: {
  pname = "python-qube-heatpump";
  version = "1.12.0";

  src = fetchFromGitHub {
    owner = "MattieGit";
    repo = "python-qube-heatpump";
    tag = "v${finalAttrs.version}";
    hash = "sha256-49zRXAWHo5+Ooo/D+Cb3ydIKD3vMIslSql5lmAHtaeA=";
  };

  nativeCheckInputs = [
    pytest-asyncio
    pytest-mock
    pytestCheckHook
  ];

  build-system = [ hatchling ];
  dependencies = [ pymodbus ];
  pyproject = true;
  pythonImportsCheck = [ "python_qube_heatpump" ];

  meta = {
    description = "Async Modbus client for Qube Heat Pumps";
    homepage = "https://github.com/MattieGit/python-qube-heatpump";
    changelog = "https://github.com/MattieGit/python-qube-heatpump/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.mit;
    maintainers = [ lib.maintainers.jamiemagee ];
  };
})
