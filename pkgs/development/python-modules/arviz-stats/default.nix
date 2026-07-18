{
  lib,
  fetchFromGitHub,
  # xarray
  arviz-base,
  buildPythonPackage,
  # build-system
  flit-core,
  # optional-dependencies
  # doc
  h5netcdf,
  jupyter-sphinx,
  myst-nb,
  myst-parser,
  # numba
  numba,
  # dependencies
  numpy,
  numpydoc,
  # test
  pytest,
  pytest-cov,
  # tests
  pytestCheckHook,
  scipy,
  sphinx,
  sphinx-book-theme,
  sphinx-copybutton,
  sphinx-design,
  xarray,
  xarray-einstats,
}:

buildPythonPackage (finalAttrs: {
  pname = "arviz-stats";
  version = "1.2.0";

  src = fetchFromGitHub {
    owner = "arviz-devs";
    repo = "arviz-stats";
    tag = "v${finalAttrs.version}";
    hash = "sha256-KA36JGqgsYs5fF1AndsTBkXQ6U/duoebDQ1TOEmaCSc=";
  };

  nativeCheckInputs = [
    pytestCheckHook
  ];

  __structuredAttrs = true;

  build-system = [
    flit-core
  ];

  dependencies = [
    numpy
    scipy
  ];

  optional-dependencies = {
    doc = [
      h5netcdf
      jupyter-sphinx
      myst-nb
      myst-parser
      numpydoc
      sphinx
      # sphinx-autosummary-accessors
      sphinx-book-theme
      sphinx-copybutton
      sphinx-design
    ];

    numba = [
      numba
      xarray-einstats
    ];

    test = [
      pytest
      pytest-cov
    ];

    test-xarray = [
      h5netcdf
      pytest
      pytest-cov
    ];

    xarray = [
      arviz-base
      xarray
      xarray-einstats
    ];
  };

  pyproject = true;
  pythonImportsCheck = [ "arviz_stats" ];

  meta = {
    description = "Statistical computation and diagnostics for ArviZ";
    homepage = "https://github.com/arviz-devs/arviz-stats";
    changelog = "https://github.com/arviz-devs/arviz-stats/blob/${finalAttrs.src.tag}/CHANGELOG.md";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ GaetanLepage ];
  };
})
