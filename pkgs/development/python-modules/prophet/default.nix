{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  cmdstanpy,
  dask,
  distributed,
  holidays,
  importlib-resources,
  matplotlib,
  numpy,
  pandas,
  pytestCheckHook,
  setuptools,
  tqdm,
}:

buildPythonPackage (finalAttrs: {
  pname = "prophet";
  version = "1.3.0";

  src = fetchFromGitHub {
    owner = "facebook";
    repo = "prophet";
    tag = "v${finalAttrs.version}";
    hash = "sha256-Bu+ztg6sj1jh2iair6v1CdbF0Fi4b+h8yLzB3xTMD3Y=";
  };

  nativeBuildInputs = [ setuptools ];

  propagatedBuildInputs = [
    cmdstanpy
    numpy
    matplotlib
    pandas
    holidays
    tqdm
    importlib-resources
  ];

  env.PROPHET_REPACKAGE_CMDSTAN = "false";
  nativeCheckInputs = [ pytestCheckHook ];

  preCheck = ''
    # use the generated files from $out for testing
    mv prophet/tests .
    rm -r prophet
  '';

  optional-dependencies.parallel = [
    dask
    distributed
  ]
  ++ dask.optional-dependencies.dataframe;

  pyproject = true;
  pythonImportsCheck = [ "prophet" ];
  sourceRoot = "${finalAttrs.src.name}/python";

  meta = {
    description = "Tool for producing high quality forecasts for time series data that has multiple seasonality with linear or non-linear growth";
    homepage = "https://facebook.github.io/prophet/";
    changelog = "https://github.com/facebook/prophet/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ tomasajt ];
  };
})
