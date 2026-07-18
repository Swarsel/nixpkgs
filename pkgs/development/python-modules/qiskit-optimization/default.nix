{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  ddt,
  # Python Inputs
  decorator,
  docplex,
  networkx,
  numpy,
  pylatexenc,
  # Check Inputs
  pytestCheckHook,
  qiskit,
  qiskit-aer,
  scipy,
  # build-system
  setuptools,
}:

buildPythonPackage rec {
  pname = "qiskit-optimization";
  version = "0.7.0";

  src = fetchFromGitHub {
    owner = "qiskit";
    repo = "qiskit-optimization";
    tag = version;
    hash = "sha256-aonL08avVZlpGQ/FCZnrsPMvu1lbhRiadzKf/oPndZk=";
  };

  postPatch = ''
    substituteInPlace requirements.txt --replace "networkx>=2.2,<2.6" "networkx"
  '';

  nativeBuildInputs = [ setuptools ];

  propagatedBuildInputs = [
    docplex
    decorator
    networkx
    numpy
    qiskit
    scipy
  ];

  nativeCheckInputs = [
    pytestCheckHook
    ddt
    pylatexenc
    qiskit-aer
  ];

  pyproject = true;
  pytestFlags = [ "--durations=10" ];
  pythonImportsCheck = [ "qiskit_optimization" ];

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
