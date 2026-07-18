{
  lib,
  fetchFromGitHub,
  absl-py,
  buildPythonPackage,
  fetchPypi,
  nltk,
  numpy,
  pytestCheckHook,
  setuptools,
  six,
}:
let
  testdata = fetchFromGitHub {
    hash = "sha256-ojqk6U2caS7Xz4iGUC9aQVHrKb2QNvMlPuQAL/jJat0=";
    owner = "google-research";
    repo = "google-research";
    rev = "1d4d2f1aa6f2883a790d2ae46a6ee8ab150d8f31";
    sparseCheckout = [ "rouge/testdata" ];
  };
in
buildPythonPackage (finalAttrs: {
  pname = "rouge-score";
  version = "0.1.2";

  src = fetchPypi {
    inherit (finalAttrs) version;
    hash = "sha256-x9TaJoPmjJq/ATXvkV1jpGZDZm+EjlWKG59+rRf/DwQ=";
    extension = "tar.gz";
    pname = "rouge_score";
  };

  # the tar file from pypi doesn't come with the test data
  postPatch = ''
    substituteInPlace rouge_score/test_util.py \
      --replace-fail \
        'os.path.join(os.path.dirname(__file__), "testdata")' \
        '"${testdata}/rouge/testdata/"'
  '';

  nativeCheckInputs = [ pytestCheckHook ];
  build-system = [ setuptools ];

  dependencies = [
    absl-py
    nltk
    numpy
    six
  ];

  disabledTests = [
    # https://github.com/google-research/google-research/issues/1203
    "testRougeLSumSentenceSplitting"
    # tries to download external tokenizers via nltk
    "testRougeLsumLarge"
  ];

  pyproject = true;
  pythonImportsCheck = [ "rouge_score" ];

  meta = {
    description = "Python ROUGE Implementation";
    homepage = "https://github.com/google-research/google-research/tree/master/rouge";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ nviets ];
  };
})
