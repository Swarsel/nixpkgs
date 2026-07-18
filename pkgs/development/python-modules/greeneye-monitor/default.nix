{
  lib,
  fetchFromGitHub,
  aiohttp,
  buildPythonPackage,
  pytest-socket,
  pytestCheckHook,
  setuptools,
  siobrultech-protocols,
}:

buildPythonPackage rec {
  pname = "greeneye-monitor";
  version = "5.0.2";

  src = fetchFromGitHub {
    owner = "jkeljo";
    repo = "greeneye-monitor";
    tag = "v${version}";
    hash = "sha256-7EDuQ+wECcTzxkEufMpg3WSzosWeiwfxcVIVtQi+0BI=";
  };

  nativeCheckInputs = [
    pytest-socket
    pytestCheckHook
  ];

  build-system = [ setuptools ];

  dependencies = [
    aiohttp
    siobrultech-protocols
  ];

  pyproject = true;
  pythonImportsCheck = [ "greeneye.monitor" ];

  meta = {
    description = "Receive data packets from GreenEye Monitor";
    homepage = "https://github.com/jkeljo/greeneye-monitor";
    changelog = "https://github.com/jkeljo/greeneye-monitor/blob/v${version}/CHANGELOG.rst";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ dotlambda ];
  };
}
