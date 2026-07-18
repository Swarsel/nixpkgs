{
  lib,
  stdenv,
  fetchFromGitHub,
  # dependencies
  anytree,
  beartype,
  buildPythonPackage,
  future,
  gensim,
  graspologic-native,
  hyppo,
  joblib,
  matplotlib,
  networkx,
  numpy,
  # build-system
  poetry-core,
  poetry-dynamic-versioning,
  pot,
  # tests
  pytestCheckHook,
  scikit-learn,
  scipy,
  seaborn,
  statsmodels,
  testfixtures,
  typing-extensions,
  umap-learn,
}:

buildPythonPackage rec {
  pname = "graspologic";
  version = "3.4.4";

  src = fetchFromGitHub {
    owner = "graspologic-org";
    repo = "graspologic";
    tag = "v${version}";
    hash = "sha256-ulsb7jD/tIVEISjnNRif7VO+ZcXCAGIFl1SNZhOC7ik=";
  };

  # Fix numpy 2 compat
  postPatch = ''
    substituteInPlace graspologic/utils/utils.py \
      --replace-fail "np.float_" "np.float64"
    substituteInPlace graspologic/embed/omni.py \
      --replace-fail \
        "A = np.array(graphs, copy=False, ndmin=3)" \
        "A = np.asarray(graphs)"
  '';

  env.NUMBA_CACHE_DIR = "$TMPDIR";

  nativeCheckInputs = [
    pytestCheckHook
    testfixtures
  ];

  build-system = [
    poetry-core
    poetry-dynamic-versioning
  ];

  dependencies = [
    anytree
    beartype
    future
    gensim
    graspologic-native
    hyppo
    joblib
    matplotlib
    networkx
    numpy
    pot
    scikit-learn
    scipy
    seaborn
    statsmodels
    typing-extensions
    umap-learn
  ];

  disabledTestPaths = [
    "docs"
  ]
  ++ lib.optionals stdenv.hostPlatform.isDarwin [
    # SIGABRT
    "tests/test_plot.py"
    "tests/test_plot_matrix.py"

    # Hang forever
    "tests/pipeline/embed/"
  ];

  disabledTests = [ "gridplot_outputs" ];

  enabledTestPaths = [
    "tests"
  ];

  pyproject = true;

  pythonRelaxDeps = [
    "beartype"
    "hyppo"
    "numpy"
    "scipy"
  ];

  meta = {
    description = "Package for graph statistical algorithms";
    homepage = "https://graspologic-org.github.io/graspologic";
    changelog = "https://github.com/graspologic-org/graspologic/releases/tag/${src.tag}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ bcdarwin ];
  };
}
