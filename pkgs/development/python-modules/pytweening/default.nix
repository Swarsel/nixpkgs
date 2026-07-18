{
  lib,
  buildPythonPackage,
  fetchPypi,
}:
buildPythonPackage rec {
  pname = "pytweening";
  version = "1.2.0";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-JDMYt3NmmAZsXzYuxcK2Q07PQpfDyOfKqKv+avTKxxs=";
  };

  checkPhase = ''
    python -m unittest tests.basicTests
  '';

  format = "setuptools";
  pythonImportsCheck = [ "pytweening" ];

  meta = {
    description = "Set of tweening / easing functions implemented in Python";
    homepage = "https://github.com/asweigart/pytweening";
    license = lib.licenses.bsd3;
    maintainers = [ ];
  };
}
