{
  lib,
  stdenv,
  buildPythonPackage,
  cmake,
  docutils,
  fetchPypi,
  fmt,
  ncurses,
  numpy,
  pygments,
  python,
  rapidjson,
  scikit-learn,
  scipy,
  spdlog,
  zlib,
}:

buildPythonPackage rec {
  pname = "vowpalwabbit";
  version = "9.10.0";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-Yyqm3MlW6UL+bCufFfzWg9mBBQNhLxR+g++ZrQ6qM/E=";
  };

  nativeBuildInputs = [ cmake ];

  buildInputs = [
    docutils
    ncurses
    pygments
    python.pkgs.boost
    zlib.dev
    spdlog
    fmt
    rapidjson
  ];

  propagatedBuildInputs = [
    numpy
    scikit-learn
    scipy
  ];

  # Python ctypes.find_library uses DYLD_LIBRARY_PATH.
  preConfigure = lib.optionalString stdenv.hostPlatform.isDarwin ''
    export DYLD_LIBRARY_PATH="${python.pkgs.boost}/lib"
  '';

  checkPhase = ''
    # check-manifest requires a git clone, not a tarball
    # check-manifest --ignore "Makefile,PACKAGE.rst,*.cc,tox.ini,tests*,examples*,src*"
    ${python.interpreter} setup.py check -ms
  '';

  # Python build script uses CMake, but we don't want CMake to do the
  # configuration.
  dontUseCmakeConfigure = true;
  format = "setuptools";
  # As we disable configure via cmake, pass explicit global options to enable
  # spdlog and fmt packages
  setupPyGlobalFlags = [ "--cmake-options=-DSPDLOG_SYS_DEP=ON;-DFMT_SYS_DEP=ON" ];

  meta = {
    description = "Vowpal Wabbit is a fast machine learning library for online learning, and this is the python wrapper for the project";
    homepage = "https://github.com/JohnLangford/vowpal_wabbit";
    license = lib.licenses.bsd3;
    maintainers = with lib.maintainers; [ teh ];
    # Test again when new version is released
    broken = stdenv.hostPlatform.isLinux;
  };
}
