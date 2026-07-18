{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  ddt,
  # Python Inputs
  fastdtw,
  numpy,
  psutil,
  pytest-timeout,
  # Check Inputs
  pytestCheckHook,
  qiskit,
  qiskit-aer,
  scikit-learn,
  # build-system
  setuptools,
  sparse,
  torch,
}:

buildPythonPackage rec {
  pname = "qiskit-machine-learning";
  version = "0.9.0";

  src = fetchFromGitHub {
    owner = "qiskit";
    repo = "qiskit-machine-learning";
    tag = version;
    hash = "sha256-l7lzdGSarj1DiC0igeyr6kP+GYYE+eGKdW9+IN+2uh8=";
  };

  nativeBuildInputs = [ setuptools ];

  propagatedBuildInputs = [
    fastdtw
    numpy
    psutil
    torch
    qiskit
    scikit-learn
    sparse
  ];

  doCheck = false; # TODO: enable. Tests fail on unstable due to some multithreading issue?

  nativeCheckInputs = [
    pytestCheckHook
    pytest-timeout
    ddt
    qiskit-aer
  ];

  disabledTestPaths = [
    "test/connectors/test_torch_connector.py" # TODO: fix, get multithreading errors with python3.9, segfaults
  ];

  disabledTests = [
    # Slow tests >10 s
    "test_readme_sample"
    "test_vqr_8"
    "test_vqr_7"
    "test_qgan_training_cg"
    "test_vqc_4"
    "test_classifier_with_circuit_qnn_and_cross_entropy_4"
    "test_vqr_4"
    "test_regressor_with_opflow_qnn_4"
    "test_qgan_save_model"
    "test_qgan_training_analytic_gradients"
    "test_qgan_training_run_algo_numpy"
    "test_ad_hoc_data"
    "test_qgan_training"
  ];

  pyproject = true;

  pytestFlags = [
    "--durations=10"
    "--showlocals"
    "-vv"
  ];

  pythonImportsCheck = [ "qiskit_machine_learning" ];

  meta = {
    description = "Software for developing quantum computing programs";
    homepage = "https://qiskit.org";
    changelog = "https://qiskit.org/documentation/release_notes.html";
    license = lib.licenses.asl20;
    maintainers = [ ];
    broken = true; # incompatible with qiskit >= 2.0 (see https://github.com/Qiskit/qiskit-machine-learning/issues/934)
    downloadPage = "https://github.com/QISKit/qiskit-optimization/releases";
  };
}
