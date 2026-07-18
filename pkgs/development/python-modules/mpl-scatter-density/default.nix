{
  lib,
  stdenv,
  fetchFromGitHub,
  buildPythonPackage,
  fast-histogram,
  matplotlib,
  numpy,
  pytest-mpl,
  pytestCheckHook,
  setuptools,
  setuptools-scm,
  wheel,
  writableTmpDirAsHomeHook,
}:

buildPythonPackage rec {
  pname = "mpl-scatter-density";
  version = "0.8";

  src = fetchFromGitHub {
    owner = "astrofrog";
    repo = "mpl-scatter-density";
    tag = "v${version}";
    hash = "sha256-pDiKJAN/4WFf5icNU/ZGOvw0jqN3eGZHgilm2oolpbE=";
  };

  # Need to set MPLBACKEND=agg for headless `matplotlib` on darwin.
  # https://github.com/matplotlib/matplotlib/issues/26292
  env.MPLBACKEND = lib.optionalString stdenv.hostPlatform.isDarwin "agg";

  nativeCheckInputs = [
    pytestCheckHook
    pytest-mpl
    writableTmpDirAsHomeHook
  ];

  build-system = [
    setuptools
    setuptools-scm
    wheel
  ];

  dependencies = [
    matplotlib
    numpy
    fast-histogram
  ];

  disabledTests = [
    # AssertionError: (240, 240) != (216, 216)
    # Erroneous pinning of figure DPI, sensitive to runtime environment
    "test_default_dpi"
  ];

  pyproject = true;
  pythonImportsCheck = [ "mpl_scatter_density" ];

  meta = {
    description = "Fast scatter density plots for Matplotlib";
    homepage = "https://github.com/astrofrog/mpl-scatter-density";
    license = lib.licenses.bsd2;
    maintainers = with lib.maintainers; [ ifurther ];
  };
}
