{
  lib,
  buildPythonPackage,
  fetchPypi,
  libGL,
  libGLU,
  libx11,
  numpy,
  setuptools,
}:

buildPythonPackage rec {
  pname = "pybullet";
  version = "3.2.7";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-BCh5240QGsdZDe5HX8at7VCLhf4Sc/27/eHYi9IA4U8=";
  };

  patches = [
    # make sure X11 and OpenGL can be found at runtime
    ./static-libs.patch
  ];

  nativeBuildInputs = [ setuptools ];

  buildInputs = [
    libGLU
    libGL
    libx11
  ];

  propagatedBuildInputs = [ numpy ];
  # Fix GCC 14 build.
  # from incompatible pointer type [-Wincompatible-pointer-types
  env.NIX_CFLAGS_COMPILE = "-Wno-error=incompatible-pointer-types";
  pyproject = true;

  meta = {
    description = "Open-source software for robot simulation, integrated with OpenAI Gym";
    homepage = "https://pybullet.org/";
    license = lib.licenses.zlib;
    maintainers = with lib.maintainers; [ timokau ];
    platforms = lib.platforms.linux;
    downloadPage = "https://github.com/bulletphysics/bullet3";
  };
}
