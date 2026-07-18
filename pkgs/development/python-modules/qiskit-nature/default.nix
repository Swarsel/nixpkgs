{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  ddt,
  # Python Inputs
  h5py,
  numpy,
  psutil,
  pylatexenc,
  pyscf,
  # Check Inputs
  pytestCheckHook,
  qiskit,
  qiskit-aer,
  rustworkx,
  scikit-learn,
  scipy,
  # build-system
  setuptools,
  withPyscf ? false,
}:

buildPythonPackage rec {
  pname = "qiskit-nature";
  version = "0.7.2";

  src = fetchFromGitHub {
    owner = "Qiskit";
    repo = "qiskit-nature";
    tag = version;
    hash = "sha256-SVzg3McB885RMyAp90Kr6/iVKw3Su9ucTob2jBckBo0=";
  };

  nativeBuildInputs = [ setuptools ];

  propagatedBuildInputs = [
    h5py
    numpy
    psutil
    qiskit
    rustworkx
    scikit-learn
    scipy
  ]
  ++ lib.optional withPyscf pyscf;

  nativeCheckInputs = [
    pytestCheckHook
    ddt
    pylatexenc
    qiskit-aer
  ];

  disabledTests = [
    "test_two_qubit_reduction" # failure cause unclear
  ];

  pyproject = true;
  pytestFlags = [ "--durations=10" ];
  pythonImportsCheck = [ "qiskit_nature" ];

  meta = {
    description = "Software for developing quantum computing programs";
    homepage = "https://qiskit.org";
    changelog = "https://qiskit.org/documentation/release_notes.html";
    license = lib.licenses.asl20;

    sourceProvenance = with lib.sourceTypes; [
      fromSource
      binaryNativeCode # drivers/gaussiand/gauopen/*.so
    ];

    maintainers = [ ];
    # broken because it depends on qiskit-algorithms which is not yet packaged in nixpkgs
    broken = true;
    downloadPage = "https://github.com/QISKit/qiskit-nature/releases";
  };
}
