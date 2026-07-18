{
  lib,
  buildPythonPackage,
  docutils,
  fetchPypi,
  pybtex,
  pytestCheckHook,
  setuptools_80,
}:

buildPythonPackage rec {
  pname = "pybtex-docutils";
  version = "1.0.3";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-On69+StZPgDowcU4qpogvKXZLYQjESRxWsyWTVHZPGs=";
  };

  nativeCheckInputs = [ pytestCheckHook ];
  build-system = [ setuptools_80 ];

  dependencies = [
    docutils
    pybtex
  ];

  pyproject = true;
  pythonImportsCheck = [ "pybtex_docutils" ];

  meta = {
    description = "Docutils backend for pybtex";
    homepage = "https://github.com/mcmtroffaes/pybtex-docutils";
    license = lib.licenses.mit;
  };
}
