{
  lib,
  buildPythonPackage,
  fetchPypi,
  setuptools,
}:
buildPythonPackage rec {
  pname = "pwinput";
  version = "1.0.3";

  src = fetchPypi {
    inherit version;
    hash = "sha256-yhqL0G4ohy11Hb1BMthjcSfCW0COo6NJN3MUpUkUJvM=";
    pname = "pwinput";
  };

  # Requires graphical environment to use pyautogui
  doCheck = false;
  build-system = [ setuptools ];
  pyproject = true;
  pythonImportsCheck = [ "pwinput" ];

  meta = {
    description = "Python module that masks password input";
    homepage = "https://github.com/asweigart/pwinput";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ bwkam ];
  };
}
