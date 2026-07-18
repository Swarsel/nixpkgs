{
  lib,
  fetchFromGitHub,
  # dependencies
  boltons,
  buildPythonPackage,
  colorama,
  gensim,
  gitpython,
  greek-accentuation,
  nltk,
  # build-system
  poetry-core,
  # tests
  pytestCheckHook,
  python-dotenv,
  pyyaml,
  rapidfuzz,
  requests,
  scikit-learn,
  scipy,
  spacy,
  stanza,
  torch,
  tqdm,
  writableTmpDirAsHomeHook,
}:
buildPythonPackage rec {
  pname = "cltk";
  version = "2.0.4";

  src = fetchFromGitHub {
    owner = "cltk";
    repo = "cltk";
    tag = "v${version}";
    hash = "sha256-tAomXxI6XsIAxQzPiUsT5t1CHrFDPkwyWtVuHXQCz2A=";
  };

  # Most of tests fail as they require local files to be present and also internet access
  doCheck = false;

  nativeCheckInputs = [
    pytestCheckHook
    writableTmpDirAsHomeHook
  ];

  build-system = [ poetry-core ];

  dependencies = [
    boltons
    gensim
    gitpython
    greek-accentuation
    nltk
    pyyaml
    rapidfuzz
    requests
    scikit-learn
    scipy
    spacy
    stanza
    torch
    tqdm
    colorama
    python-dotenv
  ];

  pyproject = true;

  pythonRelaxDeps = [
    "spacy"
  ];

  meta = {
    description = "Natural language processing (NLP) framework for pre-modern languages";
    homepage = "https://cltk.org";
    changelog = "https://github.com/cltk/cltk/releases/tag/v${version}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ kmein ];
  };
}
