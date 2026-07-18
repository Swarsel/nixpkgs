{
  lib,
  buildPythonPackage,
  fetchPypi,
  flit-core,
  nltk,
  setuptools,
}:

buildPythonPackage rec {
  pname = "textblob";
  version = "0.20.0";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-rpvvOhbOy0quPplcyMb+mKnSpv/dWJkNzWjoF+jWa54=";
  };

  # Test process requires pytestCheckHook and network access to download wordnet
  # Error: 'wordnet not found' 'Attempted to load corpora/wordnet'
  doCheck = false;
  build-system = [ flit-core ];
  dependencies = [ nltk ];
  pyproject = true;
  pythonImportsCheck = [ "textblob" ];

  meta = {
    description = "Simplified Text processing";
    homepage = "https://textblob.readthedocs.io/";
    changelog = "https://github.com/sloria/TextBlob/releases/tag/${version}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ idlip ];
  };
}
