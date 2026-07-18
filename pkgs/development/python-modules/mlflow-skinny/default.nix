{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  # dependencies
  cachetools,
  click,
  cloudpickle,
  databricks-sdk,
  fastapi,
  gitpython,
  importlib-metadata,
  mlflow,
  opentelemetry-api,
  opentelemetry-proto,
  opentelemetry-sdk,
  packaging,
  protobuf,
  pydantic,
  python-dotenv,
  pyyaml,
  requests,
  # build-system
  setuptools,
  sqlparse,
  starlette,
  typing-extensions,
  uvicorn,
}:

buildPythonPackage (finalAttrs: {
  inherit (mlflow) version;
  pname = "mlflow-skinny";

  src = fetchFromGitHub {
    owner = "mlflow";
    repo = "mlflow";
    rev = "v${finalAttrs.version}";
    hash = "sha256-e11ZncpvThb1Nt6OH+O6Do74N3dphxBiK/HIeLQMxAw=";
  };

  # No tests in the skinny subtree.
  doCheck = false;
  __structuredAttrs = true;
  build-system = [ setuptools ];

  dependencies = [
    cachetools
    click
    cloudpickle
    databricks-sdk
    fastapi
    gitpython
    importlib-metadata
    opentelemetry-api
    opentelemetry-proto
    opentelemetry-sdk
    packaging
    protobuf
    pydantic
    python-dotenv
    pyyaml
    requests
    sqlparse
    starlette
    typing-extensions
    uvicorn
  ];

  pyproject = true;
  pythonImportsCheck = [ "mlflow" ];
  sourceRoot = "${finalAttrs.src.name}/libs/skinny";

  meta = mlflow.meta // {
    description = "Lightweight version of MLflow that is designed to minimize package size";
    homepage = "https://github.com/mlflow/mlflow/tree/master/libs/skinny";
    sourceProvenance = with lib.sourceTypes; [ fromSource ];
  };
})
