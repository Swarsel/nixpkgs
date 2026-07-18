{
  lib,
  buildPythonPackage,
  fetchPypi,
  pygame,
  pytestCheckHook,
}:

buildPythonPackage rec {
  pname = "pyrect";
  version = "0.2.0";

  src = fetchPypi {
    inherit version;
    hash = "sha256-9lFV9t+bkptnyv+9V8CUfFrlRJ07WA0XgHS/+0egm3g=";
    pname = "PyRect";
  };

  nativeCheckInputs = [
    pytestCheckHook
    pygame
  ];

  format = "setuptools";
  pythonImportsCheck = [ "pyrect" ];

  meta = {
    description = "Simple module with a Rect class for Pygame-like rectangular areas";
    homepage = "https://github.com/asweigart/pyrect";
    license = lib.licenses.bsd3;
    maintainers = [ ];
  };
}
