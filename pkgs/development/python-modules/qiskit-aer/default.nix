{
  lib,
  stdenv,
  fetchFromGitHub,
  blas,
  buildPythonPackage,
  cmake,
  ninja,
  nlohmann_json,
  numpy,
  psutil,
  pybind11,
  python-dateutil,
  qiskit,
  scikit-build,
  scipy,
  spdlog,
}:

buildPythonPackage rec {
  pname = "qiskit-aer";
  version = "0.17.2";

  src = fetchFromGitHub {
    owner = "Qiskit";
    repo = "qiskit-aer";
    tag = version;
    hash = "sha256-aVmGoLMnDjV3iB9s4tvcL62zKvH/p70mqeGsxHzi3nc=";
  };

  # build fails even if setting DISABLE_CONAN flag
  postPatch = ''
    sed -i -e '/conan/d' pyproject.toml
  '';

  nativeBuildInputs = [
    cmake
    ninja
  ];

  buildInputs = [
    blas
    nlohmann_json
    spdlog
  ];

  preBuild = ''
    export DISABLE_CONAN=ON
  '';

  doCheck = false;

  build-system = [
    pybind11
    scikit-build
  ];

  dependencies = [
    scipy
    numpy
    psutil
    python-dateutil
    qiskit
  ];

  dontUseCmakeConfigure = true;
  pyproject = true;

  pythonImportsCheck = [
    "qiskit_aer"
    "qiskit_aer.primitives"
    "qiskit_aer.noise"
    "qiskit_aer.library"
    "qiskit_aer.backends.controller_wrappers"
  ];

  meta = {
    description = "High performance simulators for Qiskit";
    homepage = "https://qiskit.github.io/qiskit-aer/";
    changelog = "https://qiskit.github.io/qiskit-aer/release_notes.html";
    license = lib.licenses.asl20;
    maintainers = [ ];
    # broken on darwin for unknown reasons
    broken = stdenv.hostPlatform.isDarwin;
    downloadPage = "https://github.com/QISKit/qiskit-aer/releases";
  };
}
