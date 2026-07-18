{
  lib,
  buildPythonPackage,
  cmake,
  libxc,
  numpy,
  setuptools,
}:

buildPythonPackage {
  inherit (libxc)
    pname
    version
    src
    patches
    meta
    nativeBuildInputs
    ;

  build-system = [
    setuptools
    cmake
  ];

  dependencies = [
    numpy
  ];

  dontUseCmakeConfigure = true;
  pyproject = true;
  pythonImportsCheck = [ "pylibxc" ];
}
