{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  dataprep-ml,
  numpy,
  pandas,
  poetry-core,
  pytestCheckHook,
  scikit-learn,
  type-infer,
}:

buildPythonPackage rec {
  pname = "mindsdb-evaluator";
  version = "0.0.21";

  src = fetchFromGitHub {
    owner = "mindsdb";
    repo = "mindsdb_evaluator";
    tag = "v${version}";
    hash = "sha256-eUdGtHLbI6T7HsUqkVkTp040pbq7qVzgaldQxPAzjTc=";
  };

  nativeCheckInputs = [
    pytestCheckHook
  ];

  build-system = [ poetry-core ];

  dependencies = [
    dataprep-ml
    numpy
    pandas
    scikit-learn
    type-infer
  ];

  pyproject = true;
  pythonImportsCheck = [ "mindsdb_evaluator" ];

  pythonRelaxDeps = [
    "dataprep-ml"
    "numpy"
    "scikit-learn"
  ];

  meta = {
    description = "Model evaluation for Machine Learning pipelines";
    homepage = "https://github.com/mindsdb/mindsdb_evaluator";
    changelog = "https://github.com/mindsdb/mindsdb_evaluator/releases/tag/${src.tag}";
    license = lib.licenses.gpl3Only;
    maintainers = [ ];
  };
}
