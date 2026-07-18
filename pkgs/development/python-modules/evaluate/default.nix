{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  datasets,
  dill,
  fsspec,
  huggingface-hub,
  multiprocess,
  numpy,
  packaging,
  pandas,
  requests,
  setuptools,
  tqdm,
  xxhash,
}:

buildPythonPackage rec {
  pname = "evaluate";
  version = "0.4.6";

  src = fetchFromGitHub {
    owner = "huggingface";
    repo = "evaluate";
    tag = "v${version}";
    hash = "sha256-wK50bPJSwCNFJO0l6+15+GrbaFQNfAr/djn9JTOlwpw=";
  };

  # most tests require internet access.
  doCheck = false;
  build-system = [ setuptools ];

  dependencies = [
    datasets
    numpy
    dill
    pandas
    requests
    tqdm
    xxhash
    multiprocess
    fsspec
    huggingface-hub
    packaging
  ];

  pyproject = true;
  pythonImportsCheck = [ "evaluate" ];

  meta = {
    description = "Easily evaluate machine learning models and datasets";
    homepage = "https://huggingface.co/docs/evaluate/index";
    changelog = "https://github.com/huggingface/evaluate/releases/tag/${src.tag}";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ bcdarwin ];
    mainProgram = "evaluate-cli";
  };
}
