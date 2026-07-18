{
  lib,
  buildPythonPackage,
  fetchPypi,
  setuptools,
}:

buildPythonPackage rec {
  pname = "types-python-dateutil";
  version = "2.9.0.20251115";

  src = fetchPypi {
    inherit version;
    hash = "sha256-ikfyw5IPUqmUBWuHhjCbQxQ/qlpk1Muyci1q3avfGlg=";
    pname = "types_python_dateutil";
  };

  # Modules doesn't have tests
  doCheck = false;
  build-system = [ setuptools ];
  pyproject = true;
  pythonImportsCheck = [ "dateutil-stubs" ];

  meta = {
    description = "Typing stubs for python-dateutil";
    homepage = "https://github.com/python/typeshed";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ fab ];
  };
}
