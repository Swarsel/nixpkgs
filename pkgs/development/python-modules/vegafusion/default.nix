{
  lib,
  fetchFromGitHub,
  altair,
  anywidget,
  # Deps
  arro3-core,
  buildPythonPackage,
  # optional-dependencies
  duckdb,
  flaky,
  grpcio,
  ipykernel,
  ipywidgets,
  jupytext,
  polars,
  protobuf,
  psutil,
  pyarrow,
  pytestCheckHook,
  rustPlatform,
  scikit-image,
  selenium,
  tenacity,
  vega-datasets,
  vl-convert-python,
}:
buildPythonPackage rec {
  pname = "vegafusion";
  version = "2.0.3";

  src = fetchFromGitHub {
    owner = "hex-inc";
    repo = "vegafusion";
    tag = "v${version}";
    hash = "sha256-yiECw9WGd+03KFOWa+bwR10gQFqzx4Riy6uw2zwdc3s=";
  };

  nativeBuildInputs = with rustPlatform; [
    cargoSetupHook
    maturinBuildHook
  ];

  buildInputs = [ protobuf ];
  nativeCheckInputs = [ pytestCheckHook ] ++ optional-dependencies.test;
  buildAndTestSubdir = "vegafusion-python";

  cargoDeps = rustPlatform.fetchCargoVendor {
    inherit src;
    hash = "sha256-T/4k4ZWiO/AQvCxsbjyLMvV/zKq8ywy2rAQYMsJ73t4=";
    name = "${pname}-${version}";
  };

  dependencies = [
    arro3-core
    psutil
    altair
    ipywidgets
    vl-convert-python
    anywidget
    polars
    grpcio
    pyarrow
  ];

  disabledTests = [
    # Require network access
    "test_input_utc"
    "test_pretransform"
    "test_pretransform_specs"
    "test_transformed_data"

    # Relies on selenium's chromedriver_binary
    "test_jupyter_widget"
  ];

  optional-dependencies = {
    test = [
      duckdb
      vega-datasets
      scikit-image
      jupytext
      ipykernel
      selenium
      flaky
      tenacity
    ];
  };

  pyproject = true;
  pythonImportsCheck = [ "vegafusion" ];

  meta = with lib; {
    description = "Core tools for using VegaFusion from Python";
    homepage = "https://github.com/hex-inc/vegafusion";
    license = lib.licenses.bsd3;
    maintainers = with maintainers; [ wariuccio ];
  };
}
