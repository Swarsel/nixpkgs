{
  lib,
  buildPythonPackage,
  cmake,
  fetchPypi,
  fetchpatch,
  ninja,
  scikit-build,
  setuptools,
  swig,
}:

buildPythonPackage rec {
  pname = "py-slvs";
  version = "1.0.6";

  src = fetchPypi {
    inherit version;
    hash = "sha256-U6T/aXy0JTC1ptL5oBmch0ytSPmIkRA8XOi31NpArnI=";
    pname = "py_slvs";
  };

  patches = [
    # https://github.com/realthunder/slvs_py/pull/11
    (fetchpatch {
      hash = "sha256-LqDDx7uWq5VOkbE/aRu1JAau/DVfr40KK+L8PbBeGoU=";
      name = "cmake-4.patch";
      url = "https://github.com/realthunder/slvs_py/compare/ab95814...ad0e1f7.patch";
    })
  ];

  nativeBuildInputs = [
    swig
  ];

  build-system = [
    cmake
    ninja
    setuptools
    scikit-build
  ];

  dontUseCmakeConfigure = true;
  pyproject = true;

  pythonImportsCheck = [
    "py_slvs"
  ];

  meta = {
    description = "Python binding of SOLVESPACE geometry constraint solver";
    homepage = "https://github.com/realthunder/slvs_py";
    license = lib.licenses.gpl3Only;

    maintainers = with lib.maintainers; [
      traverseda
    ];
  };
}
