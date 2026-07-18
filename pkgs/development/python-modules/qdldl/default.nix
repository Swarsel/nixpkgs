{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  cmake,
  numpy,
  pybind11,
  pytestCheckHook,
  qdldl,
  replaceVars,
  scipy,
  setuptools,
}:

buildPythonPackage rec {
  pname = "qdldl";
  version = "0.1.7.post5";

  src = fetchFromGitHub {
    owner = "osqp";
    repo = "qdldl-python";
    tag = "v${version}";
    hash = "sha256-XHdvYWORHDYy/EIqmlmFQZwv+vK3I+rPIrvcEW1JyIw=";
  };

  # use up-to-date qdldl for CMake v4
  patches = [
    (replaceVars ./use-qdldl.patch {
      inherit qdldl;
    })
  ];

  propagatedBuildInputs = [
    qdldl
  ];

  nativeCheckInputs = [ pytestCheckHook ];

  build-system = [
    cmake
    numpy
    pybind11
    setuptools
  ];

  dependencies = [
    numpy
    scipy
  ];

  dontUseCmakeConfigure = true;
  pyproject = true;
  pythonImportsCheck = [ "qdldl" ];

  meta = {
    description = "Python interface to the QDLDL";
    homepage = "https://github.com/osqp/qdldl-python";
    changelog = "https://github.com/osqp/qdldl-python/releases/tag/${src.tag}";
    license = lib.licenses.asl20;
    maintainers = [ ];
  };
}
