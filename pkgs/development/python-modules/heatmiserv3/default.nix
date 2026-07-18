{
  lib,
  fetchFromGitHub,
  appdirs,
  buildPythonPackage,
  hatchling,
  importlib-resources,
  pyserial,
  pytestCheckHook,
  pyyaml,
}:

buildPythonPackage rec {
  pname = "heatmiserv3";
  version = "2.0.6";

  src = fetchFromGitHub {
    owner = "andylockran";
    repo = "heatmiserV3";
    tag = version;
    hash = "sha256-mwzW52g3Uz7zxL9R5zePDyxMSramEiaiVm6VPlNyNts=";
  };

  nativeCheckInputs = [ pytestCheckHook ];
  build-system = [ hatchling ];

  dependencies = [
    appdirs
    importlib-resources
    pyserial
    pyyaml
  ];

  pyproject = true;
  pythonImportsCheck = [ "heatmiserv3" ];

  pythonRemoveDeps = [
    # https://github.com/andylockran/heatmiserV3/pull/113
    "pytest"
    "pytest-cov"
  ];

  meta = {
    description = "Library to interact with Heatmiser Themostats using V3 protocol";
    homepage = "https://github.com/andylockran/heatmiserV3";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ dotlambda ];
  };
}
