{
  lib,
  buildPythonPackage,
  fetchPypi,
  # runtime
  packaging,
  # build time
  pdm-backend,
  platformdirs,
  # tests
  pytestCheckHook,
}:

let
  pname = "findpython";
  version = "0.7.1";
in
buildPythonPackage {
  inherit pname version;

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-nynmo9q9t18rOclJdywO0m6rFTCABmafNHjNqw2GfHg=";
  };

  nativeCheckInputs = [ pytestCheckHook ];
  build-system = [ pdm-backend ];

  dependencies = [
    packaging
    platformdirs
  ];

  pyproject = true;
  pythonImportsCheck = [ "findpython" ];

  meta = {
    description = "Utility to find python versions on your system";
    homepage = "https://github.com/frostming/findpython";
    changelog = "https://github.com/frostming/findpython/releases/tag/${version}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ hexa ];
    mainProgram = "findpython";
  };
}
