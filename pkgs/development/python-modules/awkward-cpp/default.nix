{
  lib,
  buildPythonPackage,
  # build-system
  cmake,
  fetchPypi,
  ninja,
  # dependencies
  numpy,
  pybind11,
  scikit-build-core,
}:

buildPythonPackage (finalAttrs: {
  pname = "awkward-cpp";
  version = "54";

  src = fetchPypi {
    inherit (finalAttrs) version;
    hash = "sha256-yVeygEvmp7oouZbEywC3RGJNS3jehGHvd4j4+OUCgo4=";
    pname = "awkward_cpp";
  };

  __structuredAttrs = true;

  build-system = [
    cmake
    ninja
    pybind11
    scikit-build-core
  ];

  dependencies = [ numpy ];
  dontUseCmakeConfigure = true;
  pyproject = true;
  pythonImportsCheck = [ "awkward_cpp" ];

  meta = {
    description = "CPU kernels and compiled extensions for Awkward Array";
    homepage = "https://github.com/scikit-hep/awkward";
    license = lib.licenses.bsd3;
    maintainers = with lib.maintainers; [ veprbl ];
  };
})
