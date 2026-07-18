{
  lib,
  buildPythonPackage,
  dawg-python,
  docopt,
  fetchPypi,
  isPy3k,
  pymorphy2-dicts-ru,
}:

buildPythonPackage rec {
  pname = "pymorphy2";
  version = "0.9.1";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-hsRHFX3uLrI0HvvkU44SgadUdWuhqjLad6iWFMWLVgw=";
  };

  propagatedBuildInputs = [
    dawg-python
    docopt
    pymorphy2-dicts-ru
  ];

  disabled = !isPy3k;
  format = "setuptools";
  pythonImportsCheck = [ "pymorphy2" ];

  meta = {
    description = "Morphological analyzer/inflection engine for Russian and Ukrainian";
    homepage = "https://github.com/kmike/pymorphy2";
    license = lib.licenses.mit;
    maintainers = [ ];
    mainProgram = "pymorphy";
  };
}
