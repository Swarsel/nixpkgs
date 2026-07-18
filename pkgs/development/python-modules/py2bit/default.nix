{
  lib,
  buildPythonPackage,
  fetchPypi,
  pytestCheckHook,
  setuptools,
  setuptools-scm,
}:

buildPythonPackage rec {
  pname = "py2bit";
  version = "0.3.3";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-Jk9b/DnXKfGsrVTHYKwE+oog1BhPS1BdnDM9LgMlN3A=";
  };

  nativeCheckInputs = [
    pytestCheckHook
  ];

  build-system = [
    setuptools
    setuptools-scm
  ];

  enabledTestPaths = [ "py2bitTest/test.py" ];
  pyproject = true;

  meta = {
    description = "File access to 2bit files";

    longDescription = ''
      A python extension, written in C, for quick access to 2bit files. The extension uses lib2bit for file access.
    '';

    homepage = "https://github.com/deeptools/py2bit";
    license = lib.licenses.mit;
  };
}
