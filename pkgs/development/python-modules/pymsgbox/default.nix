{
  lib,
  buildPythonPackage,
  fetchPypi,
  setuptools,
  tkinter,
}:

buildPythonPackage rec {
  pname = "pymsgbox";
  version = "2.0.1";

  src = fetchPypi {
    inherit version;
    hash = "sha256-mNBVxJpRHcwQ+gjDBD5xAtRo9eSzqDxtPGHfcix9eY0=";
    pname = "pymsgbox";
  };

  # Finding tests fails
  doCheck = false;
  build-system = [ setuptools ];
  dependencies = [ tkinter ];
  pyproject = true;
  pythonImportsCheck = [ "pymsgbox" ];

  meta = {
    description = "Simple, cross-platform, pure Python module for JavaScript-like message boxes";
    homepage = "https://github.com/asweigart/PyMsgBox";
    license = lib.licenses.bsd3;
    maintainers = with lib.maintainers; [ jluttine ];
  };
}
