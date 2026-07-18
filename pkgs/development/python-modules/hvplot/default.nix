{
  lib,
  fetchFromGitHub,
  # dependencies
  bokeh,
  bokeh-sampledata,
  buildPythonPackage,
  colorcet,
  dask,
  # build-system
  hatch-vcs,
  hatchling,
  holoviews,
  matplotlib,
  pandas,
  parameterized,
  plotly,
  # tests
  pytestCheckHook,
  scipy,
  selenium,
  xarray,
}:

buildPythonPackage rec {
  pname = "hvplot";
  version = "0.12.2";

  src = fetchFromGitHub {
    owner = "holoviz";
    repo = "hvplot";
    tag = "v${version}";
    hash = "sha256-hJ9lgpM3AVyDeFxobUKDNYO39NKEejSDywOgnHPEm2c=";
  };

  nativeCheckInputs = [
    pytestCheckHook
    dask
    xarray
    bokeh-sampledata
    parameterized
    selenium
    matplotlib
    scipy
    plotly
  ];

  # need to set MPLBACKEND=agg for headless matplotlib for darwin
  # https://github.com/matplotlib/matplotlib/issues/26292
  preCheck = ''
    export MPLBACKEND=agg
  '';

  build-system = [
    hatch-vcs
    hatchling
  ];

  dependencies = [
    bokeh
    colorcet
    holoviews
    pandas
  ];

  disabledTestPaths = [
    # Legacy dask-expr implementation is deprecated
    # NotImplementedError: The legacy implementation is no longer supported
    "hvplot/tests/plotting/testcore.py"
    "hvplot/tests/testcharts.py"
    "hvplot/tests/testgeowithoutgv.py"

    # All of the following below require xarray.tutorial files that require
    # downloading files from the internet (not possible in the sandbox).
    "hvplot/tests/testgeo.py"
    "hvplot/tests/testinteractive.py"
    "hvplot/tests/testui.py"
    "hvplot/tests/testutil.py"
  ];

  disabledTests = [
    # Legacy dask-expr implementation is deprecated
    # NotImplementedError: The legacy implementation is no longer supported
    "test_dask_dataframe_patched"
    "test_dask_series_patched"
  ];

  pyproject = true;
  pythonImportsCheck = [ "hvplot.pandas" ];

  meta = {
    description = "High-level plotting API for the PyData ecosystem built on HoloViews";
    homepage = "https://hvplot.pyviz.org";
    changelog = "https://github.com/holoviz/hvplot/releases/tag/${src.tag}";
    license = lib.licenses.bsd3;
    maintainers = with lib.maintainers; [ locnide ];
  };
}
