{
  lib,
  buildPythonPackage,
  fetchPypi,
  pyrect,
}:
buildPythonPackage rec {
  pname = "pygetwindow";
  version = "0.0.9";

  src = fetchPypi {
    inherit version;
    hash = "sha256-F4lDVefSswXNgy1xdwg4QBfBaYqQziT29/vwJC3Qpog=";
    pname = "PyGetWindow";
  };

  # This lib officially only works completely on Windows and partially on MacOS but pyautogui requires it
  # pythonImportsCheck = [ "pygetwindow" ];
  propagatedBuildInputs = [ pyrect ];
  doCheck = false;
  format = "setuptools";

  meta = {
    description = "Simple, cross-platform module for obtaining GUI information on applications' windows";
    homepage = "https://github.com/asweigart/PyGetWindow";
    license = lib.licenses.bsd3;
    maintainers = [ ];
  };
}
