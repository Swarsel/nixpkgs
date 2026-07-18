{
  lib,
  buildPythonPackage,
  fetchPypi,
}:

buildPythonPackage rec {
  pname = "py-sneakers";
  version = "1.0.1";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-bIhkYTzRe4uM0kbNhbDTr6TiaOEBSiCSkPJKKCivDZY=";
  };

  # Module has no tests
  doCheck = false;
  format = "setuptools";
  pythonImportsCheck = [ "py_sneakers" ];

  meta = {
    description = "Library to emulate the Sneakers movie effect";
    homepage = "https://github.com/aenima-x/py-sneakers";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ fab ];
    mainProgram = "py-sneakers";
  };
}
