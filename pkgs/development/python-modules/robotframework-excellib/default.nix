{
  lib,
  buildPythonPackage,
  fetchPypi,
  openpyxl,
  robotframework,
  setuptools,
}:

buildPythonPackage rec {
  pname = "robotframework-excellib";
  version = "2.0.1";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-ZzAwlYM8DgWD1hfWRnY8u2RnZc3V368kgigBApeDZYg=";
  };

  nativeBuildInputs = [ setuptools ];

  propagatedBuildInputs = [
    openpyxl
    robotframework
  ];

  # upstream has no tests
  doCheck = false;
  pyproject = true;
  pythonImportsCheck = [ "ExcelLibrary" ];

  meta = {
    description = "Robot Framework library for working with Excel documents";
    homepage = "https://github.com/peterservice-rnd/robotframework-excellib";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ dotlambda ];
  };
}
