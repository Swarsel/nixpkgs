{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  clipper,
  cmake,
  distutils,
  libnest2d,
  python,
  sip4,
}:

buildPythonPackage rec {
  pname = "pynest2d";
  version = "5.3.0";

  src = fetchFromGitHub {
    owner = "Ultimaker";
    repo = "pynest2d";
    tag = version;
    hash = "sha256-J7QFzWvqOaUx4Gfi5VLLWi0hJIyfYc0Htu2CM7ze6xA=";
  };

  postPatch = ''
    sed -i 's#''${Python3_SITEARCH}#${placeholder "out"}/${python.sitePackages}#' cmake/SIPMacros.cmake
  '';

  strictDeps = true;

  nativeBuildInputs = [
    cmake
    sip4
  ];

  propagatedBuildInputs = [
    libnest2d
    sip4
    clipper
    distutils
  ];

  env.CLIPPER_PATH = clipper.out;
  pyproject = false;

  meta = {
    description = "Python bindings for libnest2d";
    homepage = "https://github.com/Ultimaker/pynest2d";
    license = lib.licenses.lgpl3;
    platforms = lib.platforms.linux;
  };
}
