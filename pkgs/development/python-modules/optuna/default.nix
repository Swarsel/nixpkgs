{
  lib,
  stdenv,
  fetchFromGitHub,
  # tests
  addBinToPathHook,
  # dependencies
  alembic,
  # optional-dependencies
  boto3,
  buildPythonPackage,
  cmaes,
  colorlog,
  fakeredis,
  fvcore,
  google-cloud-storage,
  grpcio,
  kaleido,
  matplotlib,
  moto,
  numpy,
  packaging,
  pandas,
  plotly,
  protobuf,
  pytest-xdist,
  pytestCheckHook,
  pyyaml,
  redis,
  scikit-learn,
  scipy,
  # build-system
  setuptools,
  sqlalchemy,
  torch,
  tqdm,
  versionCheckHook,
}:

buildPythonPackage (finalAttrs: {
  pname = "optuna";
  version = "4.9.0";

  src = fetchFromGitHub {
    owner = "optuna";
    repo = "optuna";
    tag = "v${finalAttrs.version}";
    hash = "sha256-BoRy5LSzMl9w5KS9BW1uHUTcEj1ZyYp4nWykPgq6ckI=";
  };

  nativeCheckInputs = [
    addBinToPathHook
    fakeredis
    kaleido
    moto
    pytest-xdist
    pytestCheckHook
    torch
    versionCheckHook
  ]
  ++ fakeredis.optional-dependencies.lua
  ++ finalAttrs.passthru.optional-dependencies.optional;

  preCheck =
    # grpc tests are racy
    ''
      sed -i '/"grpc",/d' optuna/testing/storages.py
    ''
    # Prevents 'Fatal Python error: Aborted' on darwin during checkPhase
    + lib.optionalString stdenv.hostPlatform.isDarwin ''
      export MPLBACKEND="Agg"
    '';

  __darwinAllowLocalNetworking = true;
  __structuredAttrs = true;

  build-system = [
    setuptools
  ];

  dependencies = [
    alembic
    colorlog
    numpy
    packaging
    sqlalchemy
    tqdm
    pyyaml
  ];

  disabledTestPaths = lib.optionals stdenv.hostPlatform.isDarwin [
    # PermissionError: [Errno 13] Permission denied: '/tmp/optuna_find_free_port.lock'
    "tests/storages_tests/journal_tests/test_combination_with_grpc.py"
    "tests/storages_tests/test_grpc.py"
    "tests/storages_tests/test_storages.py"
    "tests/study_tests/test_dataframe.py"
    "tests/study_tests/test_optimize.py"
    "tests/study_tests/test_study.py"
    "tests/trial_tests/test_frozen.py"
    "tests/trial_tests/test_trial.py"
  ];

  disabledTests = [
    # ValueError: Transform failed with error code 525: error creating static canvas/context for image server
    "test_get_pareto_front_plot"
    # too narrow time limit
    "test_get_timeline_plot_with_killed_running_trials"
    # times out under load
    "test_optimize_with_progbar_timeout"
  ]
  ++ lib.optionals stdenv.hostPlatform.isDarwin [
    # ValueError: Failed to start Kaleido subprocess. Error stream
    # kaleido/executable/kaleido: line 5:  5956 Illegal instruction: 4  ./bin/kaleido $@
    "test_edf_plot_no_trials"
    "test_edf_plot_no_trials_studies"
    "test_get_optimization_history_plot"
    "test_get_timeline_plot"
    "test_plot_contour"
    "test_plot_edf_with_multiple_studies"
    "test_plot_edf_with_target"
    "test_plot_edf_with_target_name"
    "test_plot_intermediate_values"
    "test_plot_parallel_coordinate"
    "test_plot_param_importances"
    "test_plot_rank"
    "test_plot_slice"
    "test_plot_terminator_improvement"
  ];

  optional-dependencies = {
    optional = [
      boto3
      cmaes
      fvcore
      google-cloud-storage
      grpcio
      matplotlib
      pandas
      plotly
      protobuf
      redis
      scikit-learn
      scipy
    ];
  };

  pyproject = true;
  pythonImportsCheck = [ "optuna" ];

  meta = {
    description = "Hyperparameter optimization framework";
    homepage = "https://optuna.org/";
    changelog = "https://github.com/optuna/optuna/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ natsukium ];
    mainProgram = "optuna";
  };
})
