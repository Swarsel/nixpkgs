{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  # dependencies
  dill,
  filelock,
  fsspec,
  httpx,
  huggingface-hub,
  multiprocess,
  numpy,
  pandas,
  pyarrow,
  pyyaml,
  requests,
  # build-system
  setuptools,
  tqdm,
  xxhash,
}:
buildPythonPackage (finalAttrs: {
  pname = "datasets";
  version = "3.6.0";

  src = fetchFromGitHub {
    owner = "huggingface";
    repo = "datasets";
    tag = finalAttrs.version;
    hash = "sha256-/xhu0cDKfCEwrp9IzKd0+AeQky1198f9sba/pdutvAk=";
  };

  # Tests require pervasive internet access
  doCheck = false;
  # Module import will attempt to create a cache directory
  postFixup = "export HF_MODULES_CACHE=$TMPDIR";

  build-system = [
    setuptools
  ];

  dependencies = [
    dill
    filelock
    fsspec
    httpx
    huggingface-hub
    multiprocess
    numpy
    pandas
    pyarrow
    pyyaml
    requests
    tqdm
    xxhash
  ]
  ++ fsspec.optional-dependencies.http;

  pyproject = true;
  pythonImportsCheck = [ "datasets" ];

  pythonRelaxDeps = [
    # https://github.com/huggingface/datasets/blob/a256b85cbc67aa3f0e75d32d6586afc507cf535b/setup.py#L117
    # "pin until dill has official support for determinism"
    "dill"
    # https://github.com/huggingface/datasets/blob/4.5.0/setup.py#L127
    "multiprocess"
    # https://github.com/huggingface/datasets/blob/4.5.0/setup.py#L130
    "fsspec"
  ];

  meta = {
    description = "Open-access datasets and evaluation metrics for natural language processing";
    homepage = "https://github.com/huggingface/datasets";
    changelog = "https://github.com/huggingface/datasets/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.asl20;

    maintainers = with lib.maintainers; [
      osbm
      malteneuss
    ];

    mainProgram = "datasets-cli";
  };
})
