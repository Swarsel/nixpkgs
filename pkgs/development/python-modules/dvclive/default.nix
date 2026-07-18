{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  # huggingface
  datasets,
  # dependencies
  dvc,
  dvc-render,
  dvc-studio-client,
  # fastai
  fastai,
  funcy,
  gto,
  # optional-dependencies
  # all
  jsonargparse,
  lightgbm,
  lightning,
  matplotlib,
  mmcv,
  numpy,
  optuna,
  pandas,
  pillow,
  psutil,
  pynvml,
  ruamel-yaml,
  scikit-learn,
  scmrepo,
  # build-system
  setuptools-scm,
  tensorflow,
  torch,
  transformers,
  xgboost,
}:

buildPythonPackage rec {
  pname = "dvclive";
  version = "3.49.0";

  src = fetchFromGitHub {
    owner = "iterative";
    repo = "dvclive";
    tag = version;
    hash = "sha256-jjYglvXPtwPJEp2Qo309QeRLYooUmsDhO1Dc1S3OjQg=";
  };

  # Circular dependency with dvc
  doCheck = false;
  build-system = [ setuptools-scm ];

  dependencies = [
    dvc
    dvc-render
    dvc-studio-client
    funcy
    gto
    psutil
    pynvml
    ruamel-yaml
    scmrepo
  ];

  optional-dependencies = {
    all = [
      jsonargparse
      lightgbm
      lightning
      matplotlib
      mmcv
      numpy
      optuna
      pandas
      pillow
      scikit-learn
      tensorflow
      torch
      transformers
      xgboost
    ]
    ++ jsonargparse.optional-dependencies.signatures;

    # catalyst = [
    #   catalyst
    # ];
    fastai = [ fastai ];

    huggingface = [
      datasets
      transformers
    ];

    image = [
      numpy
      pillow
    ];

    lgbm = [ lightgbm ];

    lightning = [
      lightning
      torch
      jsonargparse
    ]
    ++ jsonargparse.optional-dependencies.signatures;

    markdown = [ matplotlib ];
    mmcv = [ mmcv ];
    optuna = [ optuna ];

    plots = [
      pandas
      scikit-learn
      numpy
    ];

    sklearn = [ scikit-learn ];
    tf = [ tensorflow ];
    xgb = [ xgboost ];
  };

  pyproject = true;
  pythonImportsCheck = [ "dvclive" ];

  meta = {
    description = "Library for logging machine learning metrics and other metadata in simple file formats";
    homepage = "https://github.com/iterative/dvclive";
    changelog = "https://github.com/iterative/dvclive/releases/tag/${src.tag}";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ fab ];
  };
}
