{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  click,
  cython,
  jieba,
  joblib,
  lmdb,
  marisa-trie,
  mwparserfromhell,
  numpy,
  scipy,
  setuptools,
  tqdm,
}:

buildPythonPackage rec {
  pname = "wikipedia2vec";
  version = "2.0.0";

  src = fetchFromGitHub {
    owner = "wikipedia2vec";
    repo = "wikipedia2vec";
    tag = "v${version}";
    hash = "sha256-vrBLlNm0bVIStSBWDHRCtuRpazu8JMCtBl4qJPtHGvU=";
  };

  nativeBuildInputs = [
    cython
    setuptools
  ];

  propagatedBuildInputs = [
    click
    cython
    jieba
    joblib
    lmdb
    marisa-trie
    mwparserfromhell
    numpy
    scipy
    tqdm
  ];

  preBuild = ''
    bash cythonize.sh
  '';

  pyproject = true;
  pythonImportsCheck = [ "wikipedia2vec" ];

  meta = {
    description = "Tool for learning vector representations of words and entities from Wikipedia";
    homepage = "https://wikipedia2vec.github.io/wikipedia2vec/";
    changelog = "https://github.com/wikipedia2vec/wikipedia2vec/releases/tag/v${version}";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ derdennisop ];
    mainProgram = "wikipedia2vec";
  };
}
