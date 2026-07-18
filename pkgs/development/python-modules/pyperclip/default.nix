{
  lib,
  buildPythonPackage,
  fetchPypi,
  python,
  setuptools,
}:

buildPythonPackage rec {
  pname = "pyperclip";
  version = "1.11.0";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-JEA1lj5EKFMNnjphAaHvlyCcaCXtqxVnvqwUjMwdsbY=";
  };

  # https://github.com/asweigart/pyperclip/issues/263
  doCheck = false;

  checkPhase = ''
    ${python.interpreter} tests/test_pyperclip.py
  '';

  build-system = [ setuptools ];
  pyproject = true;
  pythonImportsCheck = [ "pyperclip" ];

  meta = {
    description = "Cross-platform clipboard module";
    homepage = "https://github.com/asweigart/pyperclip";
    license = lib.licenses.bsd3;
    maintainers = with lib.maintainers; [ dotlambda ];
  };
}
