{
  lib,
  babel,
  buildPythonPackage,
  fetchPypi,
  isPy3k,
  setuptools,
}:

buildPythonPackage (finalAttrs: {
  pname = "babelgladeextractor";
  version = "0.7.0";

  src = fetchPypi {
    inherit (finalAttrs) version;
    hash = "sha256-vPgF4otLsYyLaQmmWnz1x8K8v0rlCxZIeMloLSInF5g=";
    extension = "tar.bz2";
    pname = "BabelGladeExtractor";
  };

  # SyntaxError: Non-ASCII character '\xc3' in file /build/BabelGladeExtractor-0.6.3/babelglade/tests/test_translate.py on line 20, but no encoding declared; see http://python.org/dev/peps/pep-0263/ for details
  doCheck = isPy3k;
  __structuredAttrs = true;
  build-system = [ setuptools ];
  dependencies = [ babel ];
  disabled = (!isPy3k); # uses python3 specific file io in setup.py
  pyproject = true;
  pythonImportsCheck = [ "babelglade" ];

  meta = {
    description = "Babel Glade XML files translatable strings extractor";
    homepage = "https://github.com/gnome-keysign/babel-glade";
    license = lib.licenses.bsd3;
    maintainers = [ ];
  };
})
