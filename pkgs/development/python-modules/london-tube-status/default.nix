{
  lib,
  fetchFromGitHub,
  aiohttp,
  buildPythonPackage,
  pytestCheckHook,
  requests-mock,
  setuptools,
}:

buildPythonPackage rec {
  pname = "london-tube-status";
  version = "0.7";

  src = fetchFromGitHub {
    owner = "robmarkcole";
    repo = "London-tube-status";
    tag = version;
    hash = "sha256-0uDCrF3abx94X47LQxgALirSF/spJPVD91G2WqXaDVs=";
  };

  # Tests are currently broken
  # https://github.com/robmarkcole/London-tube-status/issues/7
  doCheck = false;

  nativeCheckInputs = [
    pytestCheckHook
    requests-mock
  ];

  build-system = [
    setuptools
  ];

  dependencies = [
    aiohttp
  ];

  pyproject = true;

  pythonImportsCheck = [
    "london_tube_status"
  ];

  meta = {
    description = "Parse London tube data from TFL into a dictionary";
    homepage = "https://github.com/robmarkcole/London-tube-status";
    license = lib.licenses.asl20;
    maintainers = [ lib.maintainers.jamiemagee ];
  };
}
