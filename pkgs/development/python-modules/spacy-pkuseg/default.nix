{
  lib,
  buildPythonPackage,
  cython,
  fetchPypi,
  numpy,
  setuptools,
  srsly,
}:

buildPythonPackage rec {
  pname = "spacy-pkuseg";
  version = "1.0.1";

  src = fetchPypi {
    inherit version;
    hash = "sha256-tIB4d1r/80kUN1NE1W9wo37ARBiMyuzj9wgG/TIqR+s=";
    pname = "spacy_pkuseg";
  };

  # Does not seem to have actual tests, but unittest discover
  # recognizes some non-tests as tests and fails.
  doCheck = false;

  build-system = [
    cython
    numpy
    setuptools
  ];

  dependencies = [
    numpy
    srsly
  ];

  pyproject = true;
  pythonImportsCheck = [ "spacy_pkuseg" ];

  meta = {
    description = "Toolkit for multi-domain Chinese word segmentation (spaCy fork)";
    homepage = "https://github.com/explosion/spacy-pkuseg";
    license = lib.licenses.mit;
    maintainers = [ ];
  };
}
