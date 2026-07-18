{
  lib,
  stdenv,
  fetchFromGitHub,
  buildPythonPackage,
  cloudpickle,
  dask,
  distributed,
  ipython,
  matplotlib,
  mock,
  notebook,
  numpy,
  pandas,
  pandas-datareader,
  patsy,
  pytest-cov-stub,
  pytest-xdist,
  pytestCheckHook,
  pywavelets,
  requests,
  scikit-learn,
  scipy,
  seaborn,
  setuptools,
  statsmodels,
  stumpy,
  tqdm,
}:

buildPythonPackage rec {
  pname = "tsfresh";
  version = "0.21.1";

  src = fetchFromGitHub {
    owner = "blue-yonder";
    repo = "tsfresh";
    tag = "v${version}";
    hash = "sha256-KwUI33t5KFcTUWdSDg81OPbNn5SYv4Gw/0dPjCB502w=";
  };

  patches = [
    # The pyscaffold is not a build dependency but just a python project bootstrapping tool, so we do not need it
    ./remove-pyscaffold.patch
  ];

  # python-datareader is disabled on Python 3.12+ and is require only for checks.
  doCheck = !pandas-datareader.disabled;

  nativeCheckInputs = [
    pytestCheckHook
    pytest-cov-stub
    pytest-xdist
    mock
    matplotlib
    seaborn
    ipython
    notebook
    pandas-datareader
  ];

  dependencies = [
    setuptools
    requests
    numpy
    pandas
    scipy
    statsmodels
    patsy
    scikit-learn
    tqdm
    dask
    distributed
    stumpy
    cloudpickle
    pywavelets
  ]
  ++ dask.optional-dependencies.dataframe;

  disabledTests = [
    # touches network
    "test_relevant_extraction"
    "test_characteristics_downloaded_robot_execution_failures"
    "test_index"
    "test_binary_target_is_default"
    "test_characteristics_downloaded_robot_execution_failures"
    "test_extraction_runs_through"
    "test_multilabel_target_on_request"
  ]
  ++ lib.optionals stdenv.hostPlatform.isDarwin [
    # RuntimeError: Cluster failed to start: [Errno 1] Operation not permitted
    # may require extra privileges on darwin
    "test_local_dask_cluster_extraction_one_worker"
    "test_local_dask_cluster_extraction_two_worker"
    "test_dask_cluster_extraction_one_worker"
    "test_dask_cluster_extraction_two_workers"
  ];

  pyproject = true;
  pythonImportsCheck = [ "tsfresh" ];

  meta = {
    description = "Automatic extraction of relevant features from time series";
    homepage = "https://github.com/blue-yonder/tsfresh";
    changelog = "https://github.com/blue-yonder/tsfresh/blob/${src.tag}/CHANGES.rst";
    license = lib.licenses.mit;
    maintainers = [ ];
    mainProgram = "run_tsfresh";
  };
}
