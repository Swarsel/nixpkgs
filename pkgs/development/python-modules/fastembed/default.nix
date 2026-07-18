{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  # dependencies
  huggingface-hub,
  loguru,
  mmh3,
  numpy,
  onnxruntime,
  pillow,
  # build-system
  poetry-core,
  py-rust-stemmers,
  pystemmer,
  requests,
  snowballstemmer,
  tokenizers,
  tqdm,
}:

buildPythonPackage rec {
  pname = "fastembed";
  version = "0.8.0";

  src = fetchFromGitHub {
    owner = "qdrant";
    repo = "fastembed";
    tag = "v${version}";
    hash = "sha256-oHuu2hlEdmMjA6MDU4YQ5slu6NoYwQpsJI7mvFBSBhE=";
  };

  # there is one test and it requires network
  doCheck = false;
  build-system = [ poetry-core ];

  dependencies = [
    huggingface-hub
    loguru
    mmh3
    numpy
    onnxruntime
    pillow
    py-rust-stemmers
    pystemmer
    requests
    snowballstemmer
    tokenizers
    tqdm
  ];

  pyproject = true;
  pythonImportsCheck = [ "fastembed" ];

  pythonRelaxDeps = [
    "mmh3"
    "onnxruntime"
    "pillow"
  ];

  meta = {
    description = "Fast, Accurate, Lightweight Python library to make State of the Art Embedding";
    homepage = "https://github.com/qdrant/fastembed";
    changelog = "https://github.com/qdrant/fastembed/releases/tag/${src.tag}";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ happysalada ];
    # terminate called after throwing an instance of 'onnxruntime::OnnxRuntimeException'
    badPlatforms = [ "aarch64-linux" ];
  };
}
