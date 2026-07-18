{
  lib,
  buildPythonPackage,
  fetchPypi,
  language-data,
  marisa-trie,
  pytestCheckHook,
  setuptools,
  setuptools-scm,
}:

buildPythonPackage rec {
  pname = "langcodes";
  version = "3.5.1";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-QL/zFeAbAdEcKuOSjdT1y9dN04+b2RLBK5o2BsFD9zE=";
  };

  nativeCheckInputs = [ pytestCheckHook ];

  build-system = [
    setuptools
    setuptools-scm
  ];

  dependencies = [
    language-data
    marisa-trie
    setuptools # pkg_resources import in language_data/util.py
  ];

  disabledTests = [
    # AssertionError: assert 'Unknown language [aqk]' == 'Aninka'
    "test_updated_iana"
    # doctest mismatches
    "speaking_population"
    "writing_population"
    "README.md"
  ];

  pyproject = true;
  pythonImportsCheck = [ "langcodes" ];

  meta = {
    description = "Python toolkit for working with and comparing the standardized codes for languages";
    homepage = "https://github.com/georgkrause/langcodes";
    license = lib.licenses.mit;
  };
}
