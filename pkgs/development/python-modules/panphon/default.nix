{
  lib,
  buildPythonPackage,
  editdistance,
  fetchPypi,
  levenshtein,
  munkres,
  numpy,
  pandas,
  pyyaml,
  regex,
  setuptools,
  unicodecsv,
  unittestCheckHook,
}:

buildPythonPackage rec {
  pname = "panphon";
  version = "0.22.2";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-OD1HfVh/66HKWoKHjiT+d8FkXW++ngHJ6X1JjYopujU=";
  };

  nativeCheckInputs = [ unittestCheckHook ];
  build-system = [ setuptools ];

  dependencies = [
    unicodecsv
    pyyaml
    regex
    numpy
    editdistance
    munkres
    pandas
    levenshtein # need for align_wordlists.py script
  ];

  pyproject = true;

  pythonImportsCheck = [
    "panphon"
    "panphon.segment"
    "panphon.distance"
  ];

  unittestFlagsArray = [
    "-s"
    "test"
  ];

  meta = {
    description = "Tools for using the International Phonetic Alphabet with phonological features";
    homepage = "https://github.com/dmort27/panphon";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ vizid ];
  };
}
