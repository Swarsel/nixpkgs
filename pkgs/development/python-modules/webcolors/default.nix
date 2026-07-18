{
  lib,
  buildPythonPackage,
  fetchPypi,
  pdm-backend,
  pytestCheckHook,
}:

buildPythonPackage rec {
  pname = "webcolors";
  version = "25.10.0";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-YquuhlBPZtD2NkwqhSDeSgxHuAwD/DpfGBX+2+98Gb8=";
  };

  nativeCheckInputs = [ pytestCheckHook ];
  build-system = [ pdm-backend ];
  pyproject = true;
  pythonImportsCheck = [ "webcolors" ];

  meta = {
    description = "Library for working with color names/values defined by the HTML and CSS specifications";
    homepage = "https://github.com/ubernostrum/webcolors";
    license = lib.licenses.bsd3;
    maintainers = with lib.maintainers; [ sigmanificient ];
  };
}
