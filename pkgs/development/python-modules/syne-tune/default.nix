{
  lib,
  stdenv,
  fetchFromGitHub,
  # optional-dependencies
  autograd,
  botorch,
  buildPythonPackage,
  # dependencies
  dill,
  # configspace,
  fastparquet,
  h5py,
  huggingface-hub,
  matplotlib,
  numpy,
  pandas,
  pymoo,
  pytest-timeout,
  # yahpo-gym,
  # tests
  pytestCheckHook,
  ray,
  scikit-learn,
  scipy,
  # build-system
  setuptools,
  sortedcontainers,
  # smac,
  statsmodels,
  typing-extensions,
  writableTmpDirAsHomeHook,
  xgboost,
}:
buildPythonPackage (finalAttrs: {
  pname = "syne-tune";
  version = "0.15.0";

  src = fetchFromGitHub {
    owner = "syne-tune";
    repo = "syne-tune";
    tag = "v${finalAttrs.version}";
    hash = "sha256-UNBpfC+aLXhkbyvCG2K00yedJnpYpfldqisZ/wDPtuA=";
  };

  nativeCheckInputs = [
    pytestCheckHook
    pytest-timeout
    ray
    writableTmpDirAsHomeHook
  ]
  ++ ray.optional-dependencies.tune
  ++ finalAttrs.passthru.optional-dependencies.blackbox-repository
  ++ finalAttrs.passthru.optional-dependencies.bore
  ++ finalAttrs.passthru.optional-dependencies.botorch
  ++ finalAttrs.passthru.optional-dependencies.gpsearchers
  ++ finalAttrs.passthru.optional-dependencies.kde
  ++ finalAttrs.passthru.optional-dependencies.sklearn;

  build-system = [
    setuptools
  ];

  dependencies = [
    dill
    numpy
    pandas
    sortedcontainers
    typing-extensions
  ];

  disabledTests = [
    # NameError: name 'HV' is not defined
    # these require pkg `pymoo` and adding `pymoo` raises:
    # setuptools.errors.PackageDiscoveryError: Multiple top-level packages discovered in a flat-layout: ['cma', 'notebooks'].
    "test_append_hypervolume_indicator"
    "test_hypervolume"
    "test_hypervolume_progress"
    "test_hypervolume_simple"
  ]
  ++ lib.optionals stdenv.hostPlatform.isDarwin [
    # assert np.float64(1.0114686865847489e-12) < 1e-12
    "test_cholesky_factorization"
  ];

  optional-dependencies = lib.fix (self: {
    blackbox-repository = [
      fastparquet
      h5py
      huggingface-hub
      numpy
      pandas
      scikit-learn
      xgboost
    ];

    bore = [
      scikit-learn
      xgboost
    ];

    botorch = [ botorch ];

    gpsearchers = [
      autograd
      scipy
    ];

    kde = [ statsmodels ];

    moo = [
      pymoo
      scipy
    ];

    sklearn = [ scikit-learn ];
    # smac = [ smac swig ]; # smac unavailable on nixpkgs
    visual = [ matplotlib ];
    # yahpo = [ configspace onnxruntime pandas pyyaml yahpo-gym ]; # yahpo-gym unavailable on nixpkgs
  });

  pyproject = true;

  pythonImportsCheck = [
    "syne_tune"
  ];

  pythonRelaxDeps = [
    "numpy"
  ];

  meta = {
    description = "Large scale asynchronous hyperparameter and architecture optimization library";
    homepage = "https://github.com/syne-tune/syne-tune";
    changelog = "https://github.com/syne-tune/syne-tune/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ daspk04 ];
  };
})
