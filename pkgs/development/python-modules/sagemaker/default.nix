{
  lib,
  fetchFromGitHub,
  accelerate,
  # dependencies
  attrs,
  boto3,
  buildPythonPackage,
  cloudpickle,
  docker,
  fastapi,
  google-pasta,
  graphene,
  # build-system
  hatchling,
  importlib-metadata,
  jsonschema,
  numpy,
  omegaconf,
  packaging,
  pandas,
  pathos,
  platformdirs,
  protobuf,
  psutil,
  pyyaml,
  requests,
  sagemaker-core,
  schema,
  # optional-dependencies
  scipy,
  smdebug-rulesconfig,
  tblib,
  tqdm,
  urllib3,
  uvicorn,
}:

buildPythonPackage rec {
  pname = "sagemaker";
  version = "2.256.1";

  src = fetchFromGitHub {
    owner = "aws";
    repo = "sagemaker-python-sdk";
    tag = "v${version}";
    hash = "sha256-Q5JeXWehj2TxP4SolNvn6B6lI8yxvUYzbardJvVfgaU=";
  };

  doCheck = false; # many test dependencies are not available in nixpkgs

  build-system = [
    hatchling
  ];

  dependencies = [
    attrs
    boto3
    cloudpickle
    docker
    fastapi
    google-pasta
    graphene
    importlib-metadata
    jsonschema
    numpy
    omegaconf
    packaging
    pandas
    pathos
    platformdirs
    protobuf
    psutil
    pyyaml
    requests
    sagemaker-core
    schema
    smdebug-rulesconfig
    tblib
    tqdm
    urllib3
    uvicorn
  ];

  optional-dependencies = {
    huggingface = [ accelerate ];

    local = [
      urllib3
      docker
      pyyaml
    ];

    scipy = [ scipy ];
    # feature-processor = [ pyspark sagemaker-feature-store-pyspark ]; # not available in nixpkgs
  };

  pyproject = true;

  pythonImportsCheck = [
    "sagemaker"
    "sagemaker.lineage.visualizer"
  ];

  pythonRelaxDeps = [
    "attrs"
    "boto3"
    "cloudpickle"
    "importlib-metadata"
    "numpy"
    "omegaconf"
    "packaging"
    "protobuf"
  ];

  meta = {
    description = "Library for training and deploying machine learning models on Amazon SageMaker";
    homepage = "https://github.com/aws/sagemaker-python-sdk/";
    changelog = "https://github.com/aws/sagemaker-python-sdk/blob/${src.tag}/CHANGELOG.md";
    license = lib.licenses.asl20;
  };
}
