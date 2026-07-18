{
  lib,
  buildPythonPackage,
  fetchPypi,
  orjson,
  pandas,
  poetry-core,
  polars,
  pytest-mock,
  pytestCheckHook,
  python-dateutil,
  pyyaml,
  requests,
  tqdm,
  typer,
  websocket-client,
}:

buildPythonPackage rec {
  pname = "coinmetrics-api-client";
  version = "2026.2.9.18";

  src = fetchPypi {
    inherit version;
    hash = "sha256-5R/Z/FItszcNAdwHkhzr/HWqQBbXsYf9Hub+HGdBEGo=";
    pname = "coinmetrics_api_client";
  };

  nativeCheckInputs = [
    pytestCheckHook
    pytest-mock
  ]
  ++ lib.concatAttrValues optional-dependencies;

  __darwinAllowLocalNetworking = true;
  build-system = [ poetry-core ];

  dependencies = [
    orjson
    python-dateutil
    pyyaml
    requests
    typer
    tqdm
    websocket-client
  ];

  optional-dependencies = {
    pandas = [ pandas ];
    polars = [ polars ];
  };

  pyproject = true;
  pythonImportsCheck = [ "coinmetrics.api_client" ];
  pythonRelaxDeps = [ "typer" ];

  meta = {
    description = "Coin Metrics API v4 client library";
    homepage = "https://coinmetrics.github.io/api-client-python/site/index.html";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ centromere ];
    mainProgram = "coinmetrics";
  };
}
