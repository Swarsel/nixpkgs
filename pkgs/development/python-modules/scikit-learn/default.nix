{
  lib,
  stdenv,
  buildPythonPackage,
  # build-system
  cython,
  fetchPypi,
  gfortran,
  # native dependencies
  glibcLocales,
  joblib,
  llvmPackages,
  meson-python,
  numpy,
  pillow,
  pytest-xdist,
  pytestCheckHook,
  scipy,
  threadpoolctl,
}:

buildPythonPackage rec {
  pname = "scikit-learn";
  version = "1.8.0";

  src = fetchPypi {
    inherit version;
    hash = "sha256-m8y7O0Dj3hA1H49QaOEF0PQIOxpl+ge2Y0+8QBpih/0=";
    pname = "scikit_learn";
  };

  postPatch = ''
    substituteInPlace meson.build --replace-fail \
      "run_command('sklearn/_build_utils/version.py', check: true).stdout().strip()," \
      "'${version}',"
    substituteInPlace pyproject.toml \
      --replace-fail "meson-python>=0.17.1,<0.19.0" meson-python \
      --replace-fail "numpy>=2,<2.4.0" numpy \
      --replace-fail "scipy>=1.10.0,<1.17.0" scipy
  '';

  nativeBuildInputs = [
    gfortran
  ];

  buildInputs = [
    numpy.blas
    pillow
    glibcLocales
  ]
  ++ lib.optionals stdenv.cc.isClang [ llvmPackages.openmp ];

  env.LC_ALL = "en_US.UTF-8";
  # PermissionError: [Errno 1] Operation not permitted: '/nix/nix-installer'
  doCheck = !stdenv.hostPlatform.isDarwin;

  nativeCheckInputs = [
    pytestCheckHook
    pytest-xdist
  ];

  preCheck = ''
    cd $TMPDIR
    export HOME=$TMPDIR
  '';

  __structuredAttrs = true;

  build-system = [
    cython
    meson-python
    numpy
    scipy
  ];

  dependencies = [
    joblib
    numpy
    scipy
    threadpoolctl
  ];

  disabledTests = [
    # Skip test_feature_importance_regression - does web fetch
    "test_feature_importance_regression"

    # Fail due to new deprecation warnings in scipy
    # FIXME: reenable when fixed upstream
    "test_logistic_regression_path_convergence_fail"
    "test_linalg_warning_with_newton_solver"
    "test_newton_cholesky_fallback_to_lbfgs"

    # NuSVC memmap tests causes segmentation faults in certain environments
    # (e.g. Hydra Darwin machines) related to a long-standing joblib issue
    # (https://github.com/joblib/joblib/issues/563). See also:
    # https://github.com/scikit-learn/scikit-learn/issues/17582
    "NuSVC and memmap"
  ]
  ++ lib.optionals stdenv.hostPlatform.isAarch64 [
    # doesn't seem to produce correct results?
    # possibly relevant: https://github.com/scikit-learn/scikit-learn/issues/25838#issuecomment-2308650816
    "test_sparse_input"
  ];

  pyproject = true;

  pytestFlags = [
    # verbose build outputs needed to debug hard-to-reproduce hydra failures
    "-v"
    "--pyargs"
    "sklearn"
  ];

  pythonImportsCheck = [ "sklearn" ];

  pythonRelaxDeps = [
    "numpy"
    "scipy"
  ];

  meta = {
    description = "Set of python modules for machine learning and data mining";
    homepage = "https://scikit-learn.org";

    changelog =
      let
        major = lib.versions.major version;
        minor = lib.versions.minor version;
        dashVer = lib.replaceStrings [ "." ] [ "-" ] version;
      in
      "https://scikit-learn.org/stable/whats_new/v${major}.${minor}.html#version-${dashVer}";

    license = lib.licenses.bsd3;
    maintainers = with lib.maintainers; [ davhau ];
  };
}
