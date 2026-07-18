{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  ftfy,
  jieba,
  langcodes,
  mecab-python3,
  msgpack,
  poetry-core,
  pytestCheckHook,
  regex,
}:

buildPythonPackage rec {
  pname = "wordfreq";
  version = "3.0.2";

  src = fetchFromGitHub {
    owner = "rspeer";
    repo = "wordfreq";
    tag = "v${version}";
    hash = "sha256-ANOBbQWLB35Vz6oil6QZDpsNpKHeKUJnDKA5Q9JRVdE=";
  };

  nativeBuildInputs = [ poetry-core ];

  propagatedBuildInputs = [
    regex
    langcodes
    ftfy
    msgpack
    mecab-python3
    jieba
  ];

  nativeCheckInputs = [ pytestCheckHook ];

  disabledTests = [
    # These languages require additional dictionaries that aren't packaged
    "test_languages"
    "test_japanese"
    "test_korean"
  ];

  pyproject = true;

  meta = {
    description = "Library for looking up the frequencies of words in many languages, based on many sources of data";
    homepage = "https://github.com/rspeer/wordfreq/";
    license = lib.licenses.mit;
  };
}
