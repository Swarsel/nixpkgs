{
  lib,
  buildPythonPackage,
  fetchPypi,
  ipywidgets,
  # Python Inputs
  setuptools,
}:

buildPythonPackage rec {
  pname = "ipyvue";
  version = "1.12.0";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-QIteamTiA/xnn0R6Bx49vBeKspBpgvJIrfci/IR3P/o=";
  };

  doCheck = false; # No tests in package or GitHub
  build-system = [ setuptools ];
  dependencies = [ ipywidgets ];
  pyproject = true;
  pythonImportsCheck = [ "ipyvue" ];

  meta = {
    description = "Jupyter widgets base for Vue libraries";
    homepage = "https://github.com/mariobuikhuizen/ipyvue";
    license = lib.licenses.mit;
    maintainers = [ ];
  };
}
