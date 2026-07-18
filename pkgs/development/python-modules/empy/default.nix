{
  lib,
  buildPythonPackage,
  fetchPypi,
}:

buildPythonPackage rec {
  pname = "empy";
  version = "4.2";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-hvFeHal0Pnmi6bLLrPGhPQt/sYNbYlTrJTyXi3Iof08=";
  };

  format = "setuptools";
  pythonImportsCheck = [ "em" ];

  meta = {
    description = "Templating system for Python";
    homepage = "http://www.alcyone.com/software/empy/";
    license = lib.licenses.bsd3;
    maintainers = with lib.maintainers; [ nkalupahana ];
    mainProgram = "em.py";
  };
}
