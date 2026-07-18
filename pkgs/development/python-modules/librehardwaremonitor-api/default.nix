{
  lib,
  fetchFromGitHub,
  aiohttp,
  buildPythonPackage,
  hatchling,
  pytestCheckHook,
}:

buildPythonPackage rec {
  pname = "librehardwaremonitor-api";
  version = "1.11.1";

  src = fetchFromGitHub {
    owner = "Sab44";
    repo = "librehardwaremonitor-api";
    tag = "v${version}";
    hash = "sha256-GAJgLrfYhkdafk0DSgcNgXQ2vjtBf/kOEkkRw7i9rlE=";
  };

  nativeCheckInputs = [
    pytestCheckHook
  ];

  build-system = [ hatchling ];

  dependencies = [
    aiohttp
  ];

  pyproject = true;
  pythonImportsCheck = [ "librehardwaremonitor_api" ];

  meta = {
    description = "Python API client for LibreHardwareMonitor";
    homepage = "https://github.com/Sab44/librehardwaremonitor-api";
    license = lib.licenses.mit;
    maintainers = [ lib.maintainers.dotlambda ];
  };
}
