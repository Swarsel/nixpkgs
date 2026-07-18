{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  cmake,
  coin3d,
  libGLU,
  python,
  pythonRecompileBytecodeHook,
  soqt,
  swig,
}:

buildPythonPackage rec {
  pname = "pivy";
  version = "0.6.11";

  src = fetchFromGitHub {
    owner = "coin3d";
    repo = "pivy";
    tag = version;
    hash = "sha256-jBc7+hoG1x7KDYPbexPRwnll9qz4qA3Y1w7A7DuES2Y=";
  };

  nativeBuildInputs = [
    swig
    cmake
    pythonRecompileBytecodeHook
  ];

  buildInputs = [
    coin3d
    soqt
    libGLU # dummy buildInput that provides missing header <GL/glu.h>
  ];

  cmakeFlags = [
    (lib.cmakeBool "PIVY_USE_QT6" true)
    (lib.cmakeFeature "PIVY_Python_SITEARCH" "${placeholder "out"}/${python.sitePackages}")
  ];

  dontWrapQtApps = true;
  pyproject = false;
  pythonImportsCheck = [ "pivy" ];

  meta = {
    description = "Python binding for Coin";
    homepage = "https://github.com/coin3d/pivy/";
    license = lib.licenses.bsd0;
    maintainers = [ ];
  };
}
