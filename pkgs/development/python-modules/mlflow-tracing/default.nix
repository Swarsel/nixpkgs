{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  # dependencies
  cachetools,
  databricks-sdk,
  mlflow,
  opentelemetry-api,
  opentelemetry-proto,
  opentelemetry-sdk,
  packaging,
  protobuf,
  pydantic,
  # build-system
  setuptools,
}:
buildPythonPackage (finalAttrs: {
  inherit (mlflow) version;
  pname = "mlflow-tracing";

  src = fetchFromGitHub {
    owner = "mlflow";
    repo = "mlflow";
    rev = "v${finalAttrs.version}";
    hash = "sha256-e11ZncpvThb1Nt6OH+O6Do74N3dphxBiK/HIeLQMxAw=";
  };

  # No tests
  doCheck = false;
  __structuredAttrs = true;
  build-system = [ setuptools ];

  dependencies = [
    cachetools
    databricks-sdk
    opentelemetry-api
    opentelemetry-proto
    opentelemetry-sdk
    packaging
    protobuf
    pydantic
  ];

  pyproject = true;
  pythonImportsCheck = [ "mlflow.tracing" ];
  sourceRoot = "${finalAttrs.src.name}/libs/tracing";

  meta = {
    inherit (mlflow.meta) license;
    description = "Open-Source SDK for observability and monitoring GenAI applications";
    homepage = "https://github.com/mlflow/mlflow/tree/master/libs/tracing";

    maintainers = with lib.maintainers; [
      GaetanLepage
      gquetel
    ];
  };
})
