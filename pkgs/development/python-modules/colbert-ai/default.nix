{
  lib,
  # dependencies
  bitarray,
  buildPythonPackage,
  datasets,
  faiss,
  fetchPypi,
  flask,
  gitpython,
  ninja,
  python-dotenv,
  scipy,
  # build-system
  setuptools,
  torch,
  tqdm,
  transformers,
  ujson,
}:

buildPythonPackage rec {
  pname = "colbert-ai";
  version = "0.2.22";

  src = fetchPypi {
    inherit version;
    hash = "sha256-AK/P711xXw06cGvpDStbdKK7fEAgc4B861UVwAJqiIY=";
    pname = "colbert_ai";
  };

  # There is no tests
  doCheck = false;

  build-system = [
    setuptools
  ];

  dependencies = [
    bitarray
    datasets
    faiss
    flask
    gitpython
    python-dotenv
    ninja
    scipy
    torch
    tqdm
    transformers
    ujson
  ];

  pyproject = true;
  pythonImportsCheck = [ "colbert" ];

  meta = {
    description = "Fast and accurate retrieval model, enabling scalable BERT-based search over large text collections in tens of milliseconds";
    homepage = "https://github.com/stanford-futuredata/ColBERT";
    license = lib.licenses.mit;

    maintainers = with lib.maintainers; [
      bachp
    ];
  };
}
