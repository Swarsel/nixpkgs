{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  ddt,
  # Python Inputs
  fastdtw,
  numpy,
  pandas,
  psutil,
  pytest-timeout,
  # Check Inputs
  pytestCheckHook,
  qiskit,
  qiskit-aer,
  qiskit-optimization,
  quandl,
  scikit-learn,
  scipy,
  # build-system
  setuptools,
  yfinance,
}:

buildPythonPackage rec {
  pname = "qiskit-finance";
  version = "0.4.1";

  src = fetchFromGitHub {
    owner = "qiskit";
    repo = "qiskit-finance";
    tag = version;
    hash = "sha256-zYhYhojCzlENzgYSenwewjeVHUBX2X6eQbbzc9znBsk=";
  };

  postPatch = ''
    substituteInPlace requirements.txt --replace "pandas<1.4.0" "pandas"
  '';

  nativeBuildInputs = [ setuptools ];

  propagatedBuildInputs = [
    fastdtw
    numpy
    pandas
    psutil
    qiskit
    qiskit-optimization
    quandl
    scikit-learn
    scipy
    yfinance
  ];

  nativeCheckInputs = [
    pytestCheckHook
    pytest-timeout
    ddt
    qiskit-aer
  ];

  disabledTests = [
    # Fail due to approximation error, ~1-2%
    "test_application"

    # Tests fail b/c require internet connection. Stalls tests if enabled.
    "test_exchangedata"
    "test_yahoo"
    "test_wikipedia"
  ];

  pyproject = true;
  pytestFlags = [ "--durations=10" ];
  pythonImportsCheck = [ "qiskit_finance" ];

  meta = {
    description = "Software for developing quantum computing programs";
    homepage = "https://qiskit.org";
    changelog = "https://qiskit.org/documentation/release_notes.html";
    license = lib.licenses.asl20;
    maintainers = [ ];
    # broken because it depends on qiskit-algorithms which is not yet packaged in nixpkgs
    broken = true;
    downloadPage = "https://github.com/QISKit/qiskit-optimization/releases";
  };
}
