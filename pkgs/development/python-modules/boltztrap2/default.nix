{
  lib,
  stdenv,
  fetchFromGitLab,
  ase,
  buildPythonPackage,
  cmake,
  cython,
  matplotlib,
  netcdf4,
  numpy,
  pytestCheckHook,
  scipy,
  setuptools,
  setuptools-scm,
  spglib,
}:

buildPythonPackage rec {
  pname = "boltztrap2";
  version = "25.3.1";

  src = fetchFromGitLab {
    owner = "sousaw";
    repo = "BoltzTraP2";
    tag = "v${version}";
    hash = "sha256-eocstudmgMkuxa94txU8uqIp8HpNEuWQys7WvRRZ4as=";
  };

  postPatch = ''
    substituteInPlace external/spglib-1.9.9/CMakeLists.txt \
      --replace-fail "cmake_minimum_required(VERSION 2.4)" "cmake_minimum_required(VERSION 3.10)"
    substituteInPlace pyproject.toml \
      --replace-fail "numpy>=2.0.0" "numpy"
  '';

  nativeBuildInputs = [
    cmake
    cython
  ];

  nativeCheckInputs = [ pytestCheckHook ];

  build-system = [
    setuptools
    setuptools-scm
  ];

  dependencies = [
    spglib
    numpy
    scipy
    matplotlib
    ase
    netcdf4
  ];

  disabledTests = lib.optionals (stdenv.system != "x86_64-linux") [
    # Tests np.load numpy arrays from disk that were, apparently, saved on
    # x86_64-linux. Then these files are used to compare results of
    # calculations, which won't work as expected if running on a different
    # platform.
    "test_DOS_Si"
    "test_BTPDOS_Si"
    "test_calc_cv_Si"
    "test_fermiintegrals_Si"
    "test_fitde3D_saved_noder"
  ];

  dontUseCmakeConfigure = true;

  preInstallCheck = ''
    tar xf data.tar.xz
    rm -rf BoltzTraP2
  '';

  pyproject = true;
  pytestFlags = [ "tests" ];
  pythonImportsCheck = [ "BoltzTraP2" ];

  meta = {
    description = "Band-structure interpolator and transport coefficient calculator";
    homepage = "http://www.boltztrap.org/";
    license = lib.licenses.gpl3Plus;
    maintainers = [ ];
    mainProgram = "btp2";
  };
}
