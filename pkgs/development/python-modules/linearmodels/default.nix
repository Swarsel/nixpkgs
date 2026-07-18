{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  # build-system
  cython,
  # dependencies
  formulaic,
  meson-python,
  mypy-extensions,
  numpy,
  pandas,
  pyhdfe,
  # tests
  pytestCheckHook,
  scipy,
  setuptools-scm,
  statsmodels,
  xarray,
}:

buildPythonPackage (finalAttrs: {
  pname = "linearmodels";
  version = "7.0";

  src = fetchFromGitHub {
    owner = "bashtage";
    repo = "linearmodels";
    tag = "v${finalAttrs.version}";
    hash = "sha256-/unFszNGaEPsoXDtaS3tsLnsX4A6e7Y88O8pDrf4nKc=";
  };

  postPatch = ''
    substituteInPlace pyproject.toml \
      --replace-fail "setuptools_scm>=9.2.0,<10" "setuptools_scm"
  '';

  # tries to execute linearmodels/_build/git_version.py at build time
  # which would require keeping the .git tree
  env.SETUPTOOLS_SCM_PRETEND_VERSION = finalAttrs.version;

  nativeCheckInputs = [
    pytestCheckHook
    xarray
  ];

  preCheck = ''
    rm linearmodels/__init__.py
  '';

  build-system = [
    cython
    meson-python
    numpy
    setuptools-scm
  ];

  dependencies = [
    formulaic
    mypy-extensions
    numpy
    pandas
    pyhdfe
    scipy
    statsmodels
  ];

  disabledTestPaths = [
    # Skip long-running tests
    "linearmodels/tests/panel/test_panel_ols.py"
  ];

  pyproject = true;
  pythonImportsCheck = [ "linearmodels" ];

  meta = {
    description = "Models for panel data, system regression, instrumental variables and asset pricing";
    homepage = "https://bashtage.github.io/linearmodels/";
    changelog = "https://github.com/bashtage/linearmodels/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.ncsa;
    maintainers = with lib.maintainers; [ jherland ];
  };
})
